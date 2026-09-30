{ pkgs, ... }:
{
  imports = [ ./plasma.nix ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
      "text/html" = [ "helium.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/bitwarden" = [ "bitwarden.desktop" ];
    };
  };

  xdg.configFile."autostart/bitwarden.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Bitwarden
    Exec=${pkgs.bitwarden-desktop}/bin/bitwarden --autostart
    StartupNotify=false
    Terminal=false
  '';
}
