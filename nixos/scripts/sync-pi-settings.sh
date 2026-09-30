#!/usr/bin/env bash
set -euo pipefail

# Pi writes runtime metadata here, so only declared top-level keys are replaced.
declared="${1:?Usage: sync-pi-settings.sh declared-settings.json}"
settings="$HOME/.pi/agent/settings.json"
jq -e 'type == "object"' "$declared" >/dev/null
if [[ -e "$settings" ]]; then
  jq -e 'type == "object"' "$settings" >/dev/null
fi

mkdir -p "$(dirname "$settings")"
temporary="$(mktemp "${settings}.tmp.XXXXXX")"
trap 'rm -f "$temporary"' EXIT
if [[ -e "$settings" ]]; then
  jq --slurpfile declared "$declared" '. + $declared[0]' "$settings" > "$temporary"
else
  jq . "$declared" > "$temporary"
fi

if [[ -f "$settings" ]] && cmp -s "$settings" "$temporary"; then
  exit 0
fi
chmod 600 "$temporary"
mv "$temporary" "$settings"
trap - EXIT
