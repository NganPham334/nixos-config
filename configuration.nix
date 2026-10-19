# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  i18n.inputMethod = {    
    enable = true;    
    type = "fcitx5";
    fcitx5.settings = {
      inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "lotus";
        };
        "Groups/0/Items/0".Name = "keyboard-us";
        "Groups/0/Items/1".Name = "lotus";
      };

      globalOptions = {
        "Hotkey/TriggerKeys" = { };
	Behavior = {
          ActiveByDefault = "False";
          ShareInputState = "All";
        };
      };
    };
  };

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ngan" = {
    isNormalUser = true;
    description = "Tuong Ngan";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = config.sops.secrets.hashed_ngan.path;
  };

  users.users.root.hashedPasswordFile = config.sops.secrets.hashed_ngan.path;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.sharedModules = [ ./home/common.nix ];
  home-manager.users."ngan" = import ./home/ngan.nix;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    xinit
    sops
    age
    ncdu
    ssh-to-age
    jq
    zapret
    _7zip-zstd-rar
    xarchiver
    thunar-archive-plugin
    xfce4-pulseaudio-plugin
  ];

  # Desktop environment
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.exportConfiguration = true;
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --cmd startxfce4";
  };

  services.fcitx5-lotus = {
    enable = true;
    users = [ "ngan" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  environment.shellAliases.sops-host = "SOPS_AGE_KEY=$(sudo cat /etc/ssh/ssh_host_ed25519_key | ssh-to-age -private-key) sops";
  
  sops.secrets.ngan_ssh_key = {
    owner = "ngan";
    mode = "0400";
  };

  sops.secrets.hashed_ngan = {
    neededForUsers = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "24h";
  };

  services.openssh.settings = {
    LogLevel = "VERBOSE";
    ClientAliveInterval = 25;
    ClientAliveCountMax = 3;
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  security.sudo.extraRules = [
    {
      users = [ "ngan" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /var/log/nixos-rebuild 0755 ngan users - -"
  ];

  networking.networkmanager.dns = "systemd-resolved";

  services.zapret2 = {
    enable = true;

    profiles = {
      http = {
        parameters = [
          "--filter-tcp=80"
          "--payload=http_req"
          "--lua-desync=multidisorder:pos=1"
        ];
      };

      https = {
        parameters = [
          "--filter-tcp=443"
          "--payload=tls_client_hello"
          "--lua-desync=multidisorder:pos=1"
        ];
      };

      quic = {
        parameters = [
          "--filter-udp=443"
          "--payload=quic_initial"
          "--lua-desync=fake"
        ];
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
      Domains = [ "~." ];
      DNSOverTLS = "true";
      DNSSEC = "allow-downgrade";
    };
  };
}
