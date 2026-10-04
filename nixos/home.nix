{
  pkgs,
  inputs,
  unstablePkgs,
  ...
}:

{
  imports = [
    ./home/desktop.nix
    ./home/git.nix
    ./home/agents.nix
    ./home/nixvim
    ./home/ghostty
    ./home/shell.nix
    ./home/ssh.nix
    ./home/tmux.nix
  ];

  home.username = "kirill";
  home.homeDirectory = "/home/kirill";

  home.packages = with pkgs; [
    wget
    wl-clipboard
    xclip
    ripgrep
    mpv
    unstablePkgs.telegram-desktop
    fastfetch
    bitwarden-desktop
    flameshot
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
    uv
    nodejs

    inputs.helium.packages.${stdenv.hostPlatform.system}.default
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
