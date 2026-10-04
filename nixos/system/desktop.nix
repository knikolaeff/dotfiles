{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "mac";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xremap = {
    enable = true;
    serviceMode = "user";
    userName = "kirill";
    withKDE = true;
    watch = true;
    extraArgs = [ "--no-window-logging" ];
    # Ghostty handles Alt shortcuts itself; preserve chords with extra modifiers.
    yamlConfig = ''
      keymap:
        - exact_match: true
          application:
            not: ["/(?i)ghostty/", ""]
          remap:
            Alt-c: Ctrl-c
            Alt-v: Ctrl-v
            Alt-a: Ctrl-a
    '';
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
  ];

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
