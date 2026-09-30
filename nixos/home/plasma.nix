{ inputs, pkgs, ... }:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;
    # Keep unrelated app state and KDE's generated values.
    overrideConfig = false;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
    };

    input = {
      keyboard.switchingPolicy = "winClass";
      keyboard.layouts = [
        {
          layout = "gb";
          variant = "mac";
        }
        { layout = "ru"; }
      ];
      touchpads = [
        {
          name = "Elan Touchpad";
          vendorId = "04f3";
          productId = "0020";
          naturalScroll = true;
        }
      ];
    };

    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Alt+Shift";
      # Clear the persisted launcher binding before assigning it to Ghostty.
      "services/org.wezfurlong.wezterm.desktop"."_launch" = "none";
      "services/com.mitchellh.ghostty.desktop"."_launch" = "Meta+Return";
      kwin = {
        # Free Meta+T/W/D and arrows for terminal tabs, surfaces and panes.
        "Edit Tiles" = "Meta+Ctrl+Alt+T";
        "Overview" = "Meta+Ctrl+Alt+W";
        "Show Desktop" = "Meta+Ctrl+Alt+D";
        "Window Quick Tile Left" = "Meta+Ctrl+Alt+Left";
        "Window Quick Tile Right" = "Meta+Ctrl+Alt+Right";
        "Window Quick Tile Top" = "Meta+Ctrl+Alt+Up";
        "Window Quick Tile Bottom" = "Meta+Ctrl+Alt+Down";
        "Switch Window Left" = "Meta+Alt+Shift+Left";
        "Switch Window Right" = "Meta+Alt+Shift+Right";
        "Switch Window Up" = "Meta+Alt+Shift+Up";
        "Switch Window Down" = "Meta+Alt+Shift+Down";
      };
      plasmashell = {
        "next activity" = "Meta+A";
        "previous activity" = "Meta+Shift+A";
      };
    };

    kwin.nightLight = {
      enable = true;
      temperature.night = 2100;
    };

    configFile = {
      kdeglobals = {
        General = {
          BrowserApplication = "helium.desktop";
          TerminalApplication = "ghostty";
          TerminalService = "com.mitchellh.ghostty.desktop";
        };
        KDE.AnimationDurationFactor = 0.5;
      };
      kcminputrc."Libinput/10900/17997/G2Touch Multi-Touch by G2TSP".Enabled = false;
      kwinrc = {
        Desktops = {
          Number = 1;
          Rows = 1;
        };
        "Effect-overview".BorderActivate = 9;
        TabBox.HighlightWindows = false;
        Xwayland.Scale = 1.1;
        # This layout belongs to this laptop's desktop and built-in display.
        Desktops.Id_1 = "096f2a3c-8b8f-4ac0-8db1-6e0f28f8fdf1";
        "Tiling/096f2a3c-8b8f-4ac0-8db1-6e0f28f8fdf1/8dc77869-db22-4d06-9397-d9feefa11332" = {
          padding = 4;
          tiles = builtins.toJSON {
            layoutDirection = "horizontal";
            tiles = [
              { width = 0.25; }
              { width = 0.5; }
              { width = 0.25; }
            ];
          };
        };
      };
    };

    startup.startupScript.display-scale = {
      text = "${pkgs.kdePackages.kscreen}/bin/kscreen-doctor output.eDP-1.scale.1.1";
      runAlways = true;
    };

    panels = [
      {
        location = "bottom";
        height = 46;
        floating = true;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              hidden = [ "org.kde.plasma.bluetooth" ];
              extra = [
                "org.kde.plasma.mediacontroller"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.cameraindicator"
                "org.kde.plasma.manage-inputmethod"
                "org.kde.plasma.devicenotifier"
                "org.kde.plasma.notifications"
                "org.kde.plasma.volume"
                "org.kde.plasma.keyboardlayout"
                "org.kde.kscreen"
                "org.kde.plasma.weather"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.printmanager"
                "org.kde.plasma.keyboardindicator"
                "org.kde.plasma.battery"
                "org.kde.plasma.brightness"
                "org.kde.plasma.bluetooth"
              ];
            };
          }
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}
