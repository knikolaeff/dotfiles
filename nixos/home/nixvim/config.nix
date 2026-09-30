{ config, pkgs, ... }:

let
  flake = ''builtins.getFlake "/home/kirill/dotfiles/nixos"'';
  nixos = "(${flake}).nixosConfigurations.t480s";
in
{
  globals.mapleader = " ";

  opts = {
    number = true;
    clipboard = "unnamedplus";
    undofile = true;
    signcolumn = "yes";
    ignorecase = true;
    smartcase = true;
    splitbelow = true;
    splitright = true;
    confirm = true;
    cursorline = true;
  };

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
    fd
    fzf
    ripgrep
  ];

  plugins = {
    blink-cmp = {
      enable = true;
      settings.keymap.preset = "enter";
    };
    treesitter = {
      enable = true;
      grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
        bash
        nix
        php
        python
        ruby
      ];
      highlight.enable = true;
      indent.enable = true;
    };

    fzf-lua = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          action = "files";
          options.desc = "Find files";
        };
        "<leader>fg" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Buffers";
        };
      };
    };

    gitsigns.enable = true;

    lualine.enable = true;

    neo-tree.enable = true;

    lint = {
      enable = true;
      lintersByFt.nix = [
        "statix"
        "deadnix"
      ];
    };

    lsp = {
      enable = true;

      keymaps.lspBuf = {
        gd = "definition";
        gr = "references";
        "<leader>cr" = "rename";
        "<leader>ca" = "code_action";
      };

      servers.basedpyright.enable = true;
      servers.phpactor.enable = true;
      servers.ruby_lsp.enable = true;

      servers.nixd = {
        enable = true;

        settings = {
          nixpkgs.expr = "${nixos}.pkgs";

          formatting.command = [ "nixfmt" ];

          options = {
            nixos.expr = "${nixos}.options";
            home_manager.expr = "${nixos}.options.home-manager.users.type.getSubOptions []";
          };
        };
      };
    };
  };

  keymaps = [
    {
      options.desc = "Toggle file explorer";
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
    }
    {
      options.desc = "Format buffer";
      mode = "n";
      key = "<leader>cf";
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
