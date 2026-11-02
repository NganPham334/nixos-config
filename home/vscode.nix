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
        "security.workspace.trust.enabled" = false;
        "workbench.startupEditor" = "none";
        "workbench.welcomePage.experimentalOnboarding" = false;
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      };
    };
  };
}
