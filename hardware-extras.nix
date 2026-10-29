{ pkgs, ... }:

{
  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # /etc/machine-id is preserved, so don't let systemd commit it at shutdown
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Extras not captured by nixos-generate-config
  boot.kernelModules = [ "uinput" ];
  hardware.i2c.enable = true; # ddcutil monitor control
}
