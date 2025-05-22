let
  currentVersion = "25.05";
in
{
  description = "NixOS-B550";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-${currentVersion}";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-${currentVersion}";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    scripts = {
      url = "github:mow44/scripts/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    dmenu = {
      url = "github:mow44/dmenu/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slock = {
      url = "github:mow44/slock/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slstatus = {
      url = "github:mow44/slstatus/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home = {
      url = "github:mow44/home/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        helix.follows = "helix";
        slstatus.follows = "slstatus";
      };
    };

    dwm = {
      url = "github:mow44/dwm/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        scripts.follows = "scripts";
        dmenu.follows = "dmenu";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      home,
      slock,
      dwm,
      scripts,
      ...
    }:
    {
      nixosConfigurations = {
        B550 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              slock
              dwm
              scripts
              ;
          };
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            (home.makeHomeModule "a" currentVersion)
          ];
        };
      };
    };
}
