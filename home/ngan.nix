{ osConfig, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    keepassxc
    opencode
    fastfetch
    btop
    gcr_3
  ];

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
    SSH_ASKPASS = "${pkgs.gcr_3}/libexec/gcr-ssh-askpass";
  };

  services.ssh-agent.enable = true;

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
