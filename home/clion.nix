{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.clion

    # Toolchain: CLion bundles no compiler on Linux (per JetBrains install docs)
    gcc
    cmake
    gdb
    ninja
  ];

  # Plugins are managed declaratively when needed:
  #   nixpkgs (NixOS-patched):
  #     (pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.clion [ "github-copilot--your-ai-pair-programmer" ])
  #   any Marketplace plugin via the nix-jetbrains-plugins flake:
  #     (nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs "clion" [ "<plugin-id>" ])
  # GUI-installed plugins don't survive reboots (impermanence).
}
