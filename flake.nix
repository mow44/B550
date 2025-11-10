{
  description = "NixOS-B550";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "github:mow44/wallpapers/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    locker = {
      url = "github:mow44/locker/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    uxn11 = {
      url = "github:mow44/uxn11/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    dexe = {
      url = "github:mow44/dexe/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    catclock = {
      url = "github:mow44/catclock/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    calendar = {
      url = "github:mow44/calendar/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    donsol = {
      url = "github:mow44/donsol/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    noodle = {
      url = "github:mow44/noodle/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    dmenu = {
      url = "github:mow44/dmenu/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    scripts = {
      url = "github:mow44/scripts/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        wallpapers.follows = "wallpapers";
        locker.follows = "locker";
        uxn11.follows = "uxn11";
        dexe.follows = "dexe";
        catclock.follows = "catclock";
        calendar.follows = "calendar";
        donsol.follows = "donsol";
        noodle.follows = "noodle";
        dmenu.follows = "dmenu";
      };
    };

    slock = {
      url = "github:mow44/slock/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slstatus = {
      url = "github:mow44/slstatus/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    home = {
      url = "github:mow44/home/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        home-manager.follows = "home-manager";
        helix.follows = "helix";
        slstatus.follows = "slstatus";
        scripts.follows = "scripts";
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
      locker,
      uxn11,
      ...
    }:
    let
      stateVersion = "25.05";
      userName = "a";
    in
    {
      nixosConfigurations = {
        B550 = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              system
              stateVersion
              userName
              slock
              dwm
              scripts
              locker
              uxn11
              ;
          };
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            (home.makeHomeModule userName stateVersion system)
          ];
        };
      };
    };
}
