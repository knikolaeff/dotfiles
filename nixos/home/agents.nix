{
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
let
  pi = unstablePkgs.pi-coding-agent;
  piSettings = pkgs.writeText "pi-settings.json" (
    builtins.toJSON {
      theme = "dark";
      defaultProvider = "openai-codex";
      packages = [ "npm:pi-web-access@0.28.0" ];
    }
  );
in
{
  home.packages = [ pi ];

  home.file = {
    ".pi/agent/AGENTS.md".source = ../files/pi/AGENTS.md;
    ".pi/agent/extensions/codex-limits.ts".source = ../files/pi/extensions/codex-limits.ts;
  };

  home.activation.syncPiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run env PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.jq
      ]
    } \
      ${pkgs.bash}/bin/bash ${../scripts/sync-pi-settings.sh} ${piSettings}
  '';

  programs.codex = {
    enable = true;
    package = unstablePkgs.codex;
  };
}
