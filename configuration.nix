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
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        gfxmodeEfi = "1920x1080";
      };
    };
    supportedFilesystems = [
      "ntfs"
    ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [
      "video=DisplayPort-0:1920x1080@60"
      "video=HDMI-A-0:1920x1080@75"
    ];
    kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_latest;
  };

  programs = {
    slock = {
      enable = true;
      package = slock.defaultPackage.x86_64-linux;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh.enable = true;
  };

  environment.systemPackages = [
    scripts.packages.x86_64-linux.default
  ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us,ru";
        options = "grp:alt_shift_toggle";
      };
      videoDrivers = [ "amdgpu" ];
      windowManager.dwm = {
        enable = true;
        package = dwm.defaultPackage.x86_64-linux;
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
    pipewire = {
      enable = false;
    };
    printing = {
      enable = true;
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    displayManager.ly.enable = true;
    picom = {
      enable = true;
      vSync = true;
    };
    blueman.enable = true;
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
  };

  system = {
    stateVersion = stateVersion;
    autoUpgrade = {
      enable = true;
      channel = "https://channels.nixos.org/nixos-unstable";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
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

  time.timeZone = "Europe/Moscow";

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
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "a"
      ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  fonts = {
    fontconfig.useEmbeddedBitmaps = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.droid-sans-mono
      # atkinson-hyperlegible-mono
      nerd-fonts.atkynson-mono
    ];
  };

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "librewolf.desktop";
        "image/png" = "feh.desktop";
        "image/jpg" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/gif" = "feh.desktop";
        "video/x-msvideo" = "vlc.desktop";
      };
    };
    # portal = {
    #   enable = true;
    #   extraPortals = [
    #     pkgs.xdg-desktop-portal
    #     pkgs.xdg-desktop-portal-gtk
    #     pkgs.xdg-desktop-portal-wlr
    #     pkgs.libsForQt5.xdg-desktop-portal-kde
    #     pkgs.lxqt.xdg-desktop-portal-lxqt
    #   ];
    # };
  };

  users.users.a = {
    isNormalUser = true;
    description = "a";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    packages = with pkgs; [
      glibcLocalesUtf8
    ];
  };
}
