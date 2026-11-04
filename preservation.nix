{
  boot.tmp.cleanOnBoot = true;

  preservation = {
    enable = true;

    preserveAt."/persistent" = {
      # hide the mounts from showing up in thunar as devices
      commonMountOptions = [ "x-gvfs-hide" ];

      directories = [
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/docker"
        "/var/lib/systemd/timers"
        "/var/log"
        "/etc/NetworkManager/system-connections"
        {
          directory = "/tmp";
          mode = "1777";
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];

      users.ngan = {
        directories = [
          ".ssh"
          ".config/mozilla"
          ".mozilla"
          "nixos-config"
          ".config/equibop/sessionData"
          "Desktop"
          "Documents"
          ".config/fcitx5/conf"
          ".local/share/Steam"
          ".steam"
          ".local/state/wireplumber"
          ".config/onlyoffice"
          ".local/share/onlyoffice"
          "Games"
          "repos"
          "Storage"
          ".local/share/opencode"
          ".local/state/opencode"
          ".docker"
          ".cache/mesa_shader_cache" # without this ghostty is dog slow on first launch, even with the daemon
          ".config/chromium"
          ".cache/chromium"
        ];
      };
    };
  };
}
