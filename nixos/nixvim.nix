{ pkgs, ... }:

{
  globals.mapleader = " ";

  opts.number = true;

  files."ftplugin/nix.lua".localOpts = {
    expandtab = true;
    shiftwidth = 2;
    softtabstop = 2;
    tabstop = 2;
  };

  extraPackages = with pkgs; [
    nixfmt
    statix
    deadnix
  ];

  plugins = {
    blink-cmp = {
      enable = true;
      settings.keymap.preset = "enter";
    };
    which-key.enable = true;

    lsp = {
      enable = true;

      servers.nixd = {
        enable = true;

        settings.nixd = {
          nixpkgs.expr = "import (builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs { }";

          formatting.command = [ "nixfmt" ];

          options = {
            nixos.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.nixos.options";
            home_manager.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []";
          };
        };
      };
    };
  };

  keymaps = [
    {
      options.desc = "Format buffer";
      mode = "n";
      key = "<leader>f";
      action = "<cmd>lua vim.lsp.buf.format()<CR>";
    }
    {
      options.desc = "Show line diagnostics";
      mode = "n";
      key = "<leader>d";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    }
    {
      options.desc = "Show all diagnostics";
      mode = "n";
      key = "<leader>D";
      action = "<cmd>lua vim.diagnostic.setloclist()<CR>";
    }
  ];
}
