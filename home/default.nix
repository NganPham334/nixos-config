{ pkgs, ... }:

{
  home.username = "ngan";
  home.homeDirectory = "/home/ngan";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ghostty
    nixd
    opencode
    git
    gh
    fastfetch
    btop
  ];

  programs.firefox = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    extraLuaFiles."config" = ./hypr/hyprland.lua;
  };
}
