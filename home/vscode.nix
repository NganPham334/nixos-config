{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc
    cmake
    gdb
    ninja
    clang-tools
  ];

  programs.vscode = {
    enable = true;
    profiles.default = { 
      extensions = with pkgs.vscode-extensions; [
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        twxs.cmake
      ];
      userSettings = {
        "workbench.startupEditor" = "none";
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      };
    };
  };
}
