{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      background-opacity = 0.9;
      bell-features = "no-system,no-audio";

      foreground = "#D6D5CB";
      background = "#33322C";
      selection-foreground = "#D6D5CB";
      selection-background = "#555550";
      cursor-color = "#D6D5CB";
      cursor-text = "#33322C";
      split-divider-color = "#989B00";

      gtk-custom-css = toString (pkgs.writeText "ghostty-tabs.css" (builtins.readFile ./tabs.css));

      palette = [
        "0=#33322C"
        "1=#E87A64"
        "2=#78B87A"
        "3=#A5A83D"
        "4=#78A8E0"
        "5=#DE7BAA"
        "6=#00B7BF"
        "7=#D6D5CB"
        "8=#9D9B91"
        "9=#FF9A82"
        "10=#8FCC91"
        "11=#CBCF00"
        "12=#91BAEC"
        "13=#EE91BE"
        "14=#00F4FF"
        "15=#D6D5CB"
      ];

      keybind = [
        # Use physical Alt as Command and keep Ctrl+C for stopping commands.
        "alt+c=copy_to_clipboard"
        "alt+v=paste_from_clipboard"
        "alt+a=select_all"
        "alt+f=start_search"
        "alt+n=new_window"
        "alt+equal=increase_font_size:1"
        "alt+plus=increase_font_size:1"
        "alt+minus=decrease_font_size:1"
        "alt+0=reset_font_size"
        "alt+t=new_tab"
        "alt+d=new_split:right"
        "alt+shift+d=new_split:down"
        "alt+left=previous_tab"
        "alt+h=previous_tab"
        "alt+right=next_tab"
        "alt+l=next_tab"
        "super+alt+left=goto_split:left"
        "super+alt+h=goto_split:left"
        "super+alt+right=goto_split:right"
        "super+alt+l=goto_split:right"
        "super+alt+up=goto_split:up"
        "super+alt+k=goto_split:up"
        "super+alt+down=goto_split:down"
        "super+alt+j=goto_split:down"
        "alt+w=close_surface"
      ];
    };
  };
}
