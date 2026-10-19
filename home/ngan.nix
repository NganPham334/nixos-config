{ osConfig, pkgs, inputs, ... }:

{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  home.packages = with pkgs; [
    nixd
    keepassxc
    opencode
    fastfetch
    btop
    gcr_3
    protontricks
  ];

  programs.nixcord = {
    enable = true;
    discord.enable = false;

    vesktop = {
      enable = true;

      settings = {
        hardwareVideoAcceleration = true;
        staticTitle = true;
        customTitleBar = true;
        tray = false;
        minimizeToTray = false;
      };

      state = {
        firstLaunch = false;

        windowBounds = {
          x = 310;
          y = 214;
          width = 1325;
          height = 621;
        };

        maximized = false;
        minimized = false;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "NganPham334";
      user.email = "189833900+NganPham334@users.noreply.github.com";
      init.defaultBranch = "main";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  home.sessionVariables = {
    
  };

  services.ssh-agent.enable = true;
  
  systemd.user.services.ssh-agent.Service.Environment = [
    "SSH_ASKPASS=${pkgs.gcr_3}/libexec/gcr-ssh-askpass"
    "SSH_ASKPASS_REQUIRE=force"
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identityFile = osConfig.sops.secrets.ngan_ssh_key.path;
        identitiesOnly = true;
        addKeysToAgent = "confirm";
      };
    };
  };
}
