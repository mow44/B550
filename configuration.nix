{
  pkgs,
  system,
  stateVersion,
  userName,
  slock,
  dwm,
  scripts,
  locker,
  uxn11,
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
    scripts.packages.${system}.default
    locker.packages.${system}.default
    uxn11.packages.${system}.default
  ];

  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;

    packages = with pkgs; [
      nerd-fonts.atkynson-mono
      nerd-fonts.jetbrains-mono
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

    # For wg-quick: https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
    networkmanager.dns = "systemd-resolved";

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
        userName
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
    # haguichi.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    slock = {
      enable = true;
      package = slock.packages.${system}.default;
    };

    nh.enable = true;
  };

  services = {
    # logmein-hamachi.enable = true;
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

    # For wg-quick: https://wiki.nixos.org/wiki/WireGuard#wg-quick_issues_with_NetworkManager
    resolved = {
      enable = true;
    };

    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      windowManager.dwm = {
        enable = true;
        package = dwm.packages.${system}.default;
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
      channel = "https://channels.nixos.org/nixos-unstable";
      enable = true;
    };

    stateVersion = stateVersion;
  };

  time.timeZone = "Europe/Moscow";

  users.users.${userName} = {
    description = userName;
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

      # NOTE xdg-mime query default x-scheme-handler/http
      defaultApplications = {
        "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
        "application/pdf" = "org.qutebrowser.qutebrowser.desktop";

        "image/png" = "feh.desktop";
        "image/jpg" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/gif" = "feh.desktop";

        "video/x-msvideo" = "vlc.desktop";
      };
    };
  };
}
