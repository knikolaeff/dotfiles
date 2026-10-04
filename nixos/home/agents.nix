{ unstablePkgs, ... }:
{
  home.packages = [ unstablePkgs.pi-coding-agent ];

  home.file = {
    ".pi/agent/AGENTS.md".source = ../files/pi/AGENTS.md;
    ".pi/agent/extensions/codex-limits.ts" = {
      source = ../files/pi/extensions/codex-limits.ts;
      force = true;
    };
  };

  programs.codex = {
    enable = true;
    package = unstablePkgs.codex;
  };
}
