{
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  disko.devices.nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };
  };

  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64DNL0W511524W";
    type = "disk";

    content.type = "gpt";

    content.partitions.esp = {
      name = "ESP";
      size = "1536M";
      type = "EF00";

      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };

    content.partitions.swap = {
      size = "20G";

      content = {
        type = "swap";
        resumeDevice = true;
      };
    };

    content.partitions.root = {
      name = "root";
      size = "300G";

      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];

        subvolumes = {
          "/persistent" = {
            mountOptions = [
              "compress=zstd"
              "subvol=persistent"
              "noatime"
            ];
            mountpoint = "/persistent";
          };

          "/nix" = {
            mountOptions = [
              "compress=zstd"
              "subvol=nix"
              "noatime"
            ];
            mountpoint = "/nix";
          };
        };
      };
    };
  };
}
