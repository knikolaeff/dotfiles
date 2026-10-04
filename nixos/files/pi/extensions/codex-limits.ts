import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const PROVIDER = "openai-codex";
const STATUS_KEY = "codex-limits";
const USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";
const REFRESH_INTERVAL_MS = 60_000;
const MAX_RESPONSE_BYTES = 256 * 1024;

type WindowLimit = { remaining: number; minutes?: number; resetsAt?: number };

function record(value: unknown): Record<string, unknown> | undefined {
	return typeof value === "object" && value !== null && !Array.isArray(value)
		? value as Record<string, unknown>
		: undefined;
}

function number(value: unknown): number | undefined {
	const parsed = typeof value === "number" ? value : typeof value === "string" && value.trim() ? Number(value) : NaN;
	return Number.isFinite(parsed) ? parsed : undefined;
}

function accountIdFromJwt(token: string): string | undefined {
	try {
		const payload = record(JSON.parse(Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8")));
		const auth = record(payload?.["https://api.openai.com/auth"]);
		const id = auth?.chatgpt_account_id ?? payload?.["https://api.openai.com/auth.chatgpt_account_id"];
		return typeof id === "string" ? id.trim() || undefined : undefined;
	} catch {
		return undefined;
	}
}

function timestamp(value: unknown): number | undefined {
	const numeric = number(value);
	if (numeric !== undefined) {
		if (numeric <= 0) return undefined;
		return numeric >= 10_000_000_000 ? numeric / 1_000 : numeric;
	}
	if (typeof value !== "string") return undefined;
	const parsed = Date.parse(value);
	return Number.isFinite(parsed) && parsed > 0 ? parsed / 1_000 : undefined;
}

function parseWindow(value: unknown): WindowLimit | undefined {
	const window = record(value);
	const used = number(window?.used_percent);
	if (used === undefined) return undefined;
	const seconds = number(window?.limit_window_seconds);
	const minutes = seconds !== undefined && seconds > 0 ? seconds / 60 : number(window?.window_minutes);
	const resetAfter = number(window?.reset_after_seconds);
	const resetsAt = timestamp(window?.reset_at)
		?? (resetAfter !== undefined && resetAfter >= 0 ? Date.now() / 1_000 + resetAfter : undefined);
	return {
		remaining: Math.round(Math.max(0, Math.min(100, 100 - used))),
		minutes: minutes !== undefined && minutes > 0 ? minutes : undefined,
		resetsAt,
	};
}

async function readUsagePayload(response: Response): Promise<unknown> {
	if (!response.body) throw new Error("Usage response had no body");
	const chunks: Uint8Array[] = [];
	let bytes = 0;
	for await (const chunk of response.body) {
		bytes += chunk.byteLength;
		if (bytes > MAX_RESPONSE_BYTES) throw new Error("Usage response was too large");
		chunks.push(chunk);
	}
	return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function resetCountdown(resetsAt: number | undefined): string {
	if (resetsAt === undefined) return "";
	const minutes = Math.max(0, Math.ceil((resetsAt * 1_000 - Date.now()) / 60_000));
	if (minutes === 0) return " (now)";
	if (minutes < 60) return ` (${minutes}m)`;
	if (minutes < 1_440) {
		const remainder = minutes % 60;
		return ` (${Math.floor(minutes / 60)}h${remainder ? `${remainder}m` : ""})`;
	}
	const hours = Math.floor((minutes % 1_440) / 60);
	return ` (${Math.floor(minutes / 1_440)}d${hours ? `${hours}h` : ""})`;
}

function formatWindow(window: WindowLimit, fallback: string): string {
	const minutes = window.minutes;
	let label = fallback;
	if (minutes !== undefined) {
		if (minutes % 1_440 === 0) label = `${minutes / 1_440}D`;
		else if (minutes % 60 === 0) label = `${minutes / 60}H`;
		else label = `${Math.round(minutes)}M`;
	}
	return `${label} ${window.remaining}%${resetCountdown(window.resetsAt)}`;
}

export default function (pi: ExtensionAPI) {
	let controller: AbortController | undefined;
	let timer: ReturnType<typeof setInterval> | undefined;
	let lastFetch = 0;
	let windows: (WindowLimit | undefined)[] = [];
	let failed = false;

	function cancelRefresh(): void {
		controller?.abort();
		controller = undefined;
	}

	function updateStatus(ctx: ExtensionContext): void {
		const text = windows.map((window, i) => window && formatWindow(window, i === 0 ? "P" : "S"))
			.filter(Boolean).join(" ");
		ctx.ui.setStatus(STATUS_KEY, ctx.model?.provider === PROVIDER ? text || (failed ? "limits --" : "limits …") : undefined);
	}

	async function refresh(ctx: ExtensionContext, force = false): Promise<void> {
		if (ctx.mode !== "tui" || ctx.model?.provider !== PROVIDER) return;
		if (!force && (controller || Date.now() - lastFetch < REFRESH_INTERVAL_MS)) return;
		cancelRefresh();
		const requestController = new AbortController();
		controller = requestController;
		lastFetch = Date.now();
		failed = false;
		updateStatus(ctx);
		try {
			const resolved = await ctx.modelRegistry.getProviderAuth(PROVIDER);
			// Auth resolution cannot be cancelled through ModelRegistry.
			requestController.signal.throwIfAborted();
			const token = resolved?.auth.apiKey?.trim();
			if (!token) throw new Error("OpenAI Codex is not logged in");
			const configuredHeaders = resolved?.auth.headers ?? {};
			const accountHeader = Object.entries(configuredHeaders).find(([key]) => key.toLowerCase() === "chatgpt-account-id")?.[1];
			const accountId = (typeof accountHeader === "string" ? accountHeader.trim() : undefined) || accountIdFromJwt(token);
			if (!accountId) throw new Error("Could not determine ChatGPT account");
			const signal = AbortSignal.any([requestController.signal, AbortSignal.timeout(10_000)]);
			const response = await fetch(USAGE_URL, {
				headers: { Authorization: `Bearer ${token}`, "ChatGPT-Account-Id": accountId, Accept: "application/json" },
				redirect: "manual",
				signal,
			});
			if (!response.ok) {
				await response.body?.cancel();
				throw new Error(`Usage endpoint returned ${response.status}`);
			}
			const rateLimit = record(record(await readUsagePayload(response))?.rate_limit);
			const parsed = [parseWindow(rateLimit?.primary_window), parseWindow(rateLimit?.secondary_window)];
			signal.throwIfAborted();
			if (!parsed.some(Boolean)) throw new Error("Usage response had no limits");
			windows = parsed;
		} catch {
			if (controller === requestController && !requestController.signal.aborted) {
				windows = [];
				failed = true;
			}
		} finally {
			if (controller === requestController) {
				controller = undefined;
				updateStatus(ctx);
			}
		}
	}

	pi.on("session_start", (_event, ctx) => {
		clearInterval(timer);
		cancelRefresh();
		if (ctx.mode !== "tui") return;
		windows = [];
		failed = false;
		updateStatus(ctx);
		timer = setInterval(() => {
			updateStatus(ctx);
			void refresh(ctx);
		}, REFRESH_INTERVAL_MS);
		timer.unref();
		void refresh(ctx, true);
	});
	pi.on("model_select", (event, ctx) => {
		if (ctx.mode !== "tui") return;
		if (event.model.provider === PROVIDER) void refresh(ctx, true);
		else cancelRefresh();
		updateStatus(ctx);
	});
	pi.on("agent_settled", (_event, ctx) => {
		void refresh(ctx);
	});
	pi.on("session_shutdown", (_event, ctx) => {
		clearInterval(timer);
		cancelRefresh();
		ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}
