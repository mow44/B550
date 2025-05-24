{
  pkgs,
  slock,
  dwm,
  scripts,
  stateVersion,
  ...
}:
{
  boot = {
    initrd.kernelModules = [ "amdgpu" ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_latest;
    kernelParams = [
      "video=DisplayPort-0:1920x1080@60"
      "video=HDMI-A-0:1920x1080@75"
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "1920x1080";
        useOSProber = true;
      };
    };

    supportedFilesystems = [ "ntfs" ];
  };

  documentation = {
    enable = true;
    info.enable = true;

    man = {
      enable = true;
      generateCaches = true;
      man-db.enable = true;
    };
  };

  environment.systemPackages = [
    scripts.packages.x86_64-linux.default
  ];

  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;

    packages = with pkgs; [
      nerd-fonts.atkynson-mono
    ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    steam-hardware = {
      enable = true;
    };
  };

  networking = {
    hostName = "B550";

    firewall = {
      # TODO test syncthing without settings below

      # Syncthing ports: 8384 for remote access to GUI
      # 22000 TCP and/or UDP for sync traffic
      # 21027/UDP for discovery
      # source: https://docs.syncthing.net/users/firewall.html
      allowedTCPPorts = [
        8384
        22000
      ];

      allowedUDPPorts = [
        22000
        21027
      ];

      # Enable wireguard
      logReversePathDrops = true;

      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';

      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-users = [
        "a"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    slock = {
      enable = true;
      package = slock.defaultPackage.x86_64-linux;
    };

    nh.enable = true;
  };

  services = {
    blueman.enable = true;
    displayManager.ly.enable = true;

    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    picom = {
      enable = true;
      vSync = true;
    };

    pipewire = {
      enable = false;
    };

    printing = {
      enable = true;
    };

    pulseaudio = {
      enable = true;
      support32Bit = true;
    };

    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      windowManager.dwm = {
        enable = true;
        package = dwm.defaultPackage.x86_64-linux;
      };

      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };

      xrandrHeads = [
        {
          output = "HDMI-A-0";
          primary = true;
          monitorConfig = ''
            VertRefresh 75
          '';
        }
        {
          output = "DisplayPort-0";
        }
      ];
    };
  };

  system = {
    autoUpgrade = {
      channel = "https://channels.nixos.org/nixos-25.05"; # FIXME
      enable = true;
    };

    stateVersion = stateVersion;
  };

  time.timeZone = "Europe/Moscow";

  users.users.a = {
    description = "a";
    isNormalUser = true;

    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];

    packages = with pkgs; [
      glibcLocalesUtf8
    ];
  };

  xdg = {
    mime = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/http" = "qutebrowser.desktop";
        "x-scheme-handler/https" = "qutebrowser.desktop";

        "application/pdf" = "qutebrowser.desktop";
        "image/png" = "feh.desktop";
        "image/jpg" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/gif" = "feh.desktop";
        "video/x-msvideo" = "vlc.desktop";
      };
    };
  };
}
