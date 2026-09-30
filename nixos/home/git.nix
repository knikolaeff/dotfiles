{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Kirill";
        email = "kirillnikolaefff@gmail.com";
      };
      diff.algorithm = "histogram";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.lazygit.enable = true;

  # Git reads ~/.gitconfig after the XDG config; don't leave a stale override.
  home.file.".gitconfig".text = ''
    # Git settings are managed in ~/.config/git/config by Home Manager.
  '';
}
