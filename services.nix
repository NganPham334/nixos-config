{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      LogLevel = "VERBOSE";
      ClientAliveInterval = 25;
      ClientAliveCountMax = 3;
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "24h";
  };

  virtualisation.docker.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      corefonts
      vista-fonts
      liberation_ttf
      carlito
      caladea
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };

  # extraFontPackages defaults to config.fonts.packages, so everything above
  # is baked into the app's sandboxed /usr/share/fonts automatically.
  programs.onlyoffice.enable = true;

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
    ddcutil
    caligula
  ];
}
