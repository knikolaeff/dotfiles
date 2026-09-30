{ inputs, ... }:

{
  imports = [ inputs.nixvim.homeModules.default ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    nixpkgs.useGlobalPackages = true;
    imports = [ ./config.nix ];
  };

  home.shellAliases.vim = "nvim";
}
