{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware-extras.nix
    ./networking.nix
    ./secrets.nix
    ./services.nix
    ./users.nix
  ];

  # Nix
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Time & locale
  time.timeZone = "Asia/Ho_Chi_Minh";

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

  # Desktop
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.exportConfiguration = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd startxfce4";
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

  services.fcitx5-lotus = {
    enable = true;
    users = [ "ngan" ];
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "26.05";
}
