{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc
    cmake
    gdb
    ninja
    clang-tools
    nixfmt
  ];

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        twxs.cmake
      ];
      userSettings = {
        "security.workspace.trust.enabled" = false;
        "workbench.startupEditor" = "none";
        "workbench.welcomePage.experimentalOnboarding" = false;
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "nixpkgs" = {
              "expr" = ''import (builtins.getFlake "/home/ngan/nixos-config").inputs.nixpkgs { }'';
            };
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
            "options" = {
              "nixos" = {
                "expr" = ''(builtins.getFlake "/home/ngan/nixos-config").nixosConfigurations.nixos.options'';
              };
              "home-manager" = {
                "expr" =
                  ''(builtins.getFlake "/home/ngan/nixos-config").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []'';
              };
            };
          };
        };
      };
    };
  };
}
