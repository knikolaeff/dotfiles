{ pkgs, inputs, ... }:

let
  unstablePkgs = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  home.username = "kirill";
  home.homeDirectory = "/home/kirill";

  home.packages = with pkgs; [
    git
    wget
    mpv
    codex
    unstablePkgs.telegram-desktop
    unstablePkgs.pi-coding-agent
    fastfetch
    bitwarden-desktop
    flameshot
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
    uv

    inputs.helium.packages.${stdenv.hostPlatform.system}.default
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      [[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "robbyrussell";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings."*" = {
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;
    };
  };

  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13.0;
    };

    settings = {
      enable_audio_bell = false;
      background_opacity = 0.9;

      # Generated from ~/Pictures/Shishki.jpg with Wallust:
      # wallust -N -s -T run -b wal -c lchansi -p ansidark16 --print-scheme Shishki.jpg
      foreground = "#D6D5CB";
      background = "#33322C";
      selection_foreground = "#D6D5CB";
      selection_background = "#555550";
      cursor = "#D6D5CB";
      cursor_text_color = "#33322C";

      active_border_color = "#989B00";
      inactive_border_color = "#555550";
      active_tab_foreground = "#33322C";
      active_tab_background = "#D6D5CB";
      inactive_tab_foreground = "#D6D5CB";
      inactive_tab_background = "#555550";

      color0 = "#33322C";
      color1 = "#E87A64";
      color2 = "#78B87A";
      color3 = "#A5A83D";
      color4 = "#78A8E0";
      color5 = "#DE7BAA";
      color6 = "#00B7BF";
      color7 = "#D6D5CB";
      color8 = "#9D9B91";
      color9 = "#FF9A82";
      color10 = "#8FCC91";
      color11 = "#CBCF00";
      color12 = "#91BAEC";
      color13 = "#EE91BE";
      color14 = "#00F4FF";
      color15 = "#D6D5CB";
    };
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    imports = [ ./nixvim.nix ];
  };

  home.shellAliases = {
    vim = "nvim";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
