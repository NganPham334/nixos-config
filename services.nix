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
