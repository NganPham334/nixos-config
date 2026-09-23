{ pkgs, ... }:

{
  home.username = "ngan";
  home.homeDirectory = "/home/ngan";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    nixd
    opencode
    git
    gh
    fastfetch
    btop
    vesktop
  ];

  programs.firefox = {
    enable = true;
  };
}
