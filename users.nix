{ config, inputs, ... }:

{
  users.users."ngan" = {
    isNormalUser = true;
    description = "Tuong Ngan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
    ];
    hashedPasswordFile = config.sops.secrets.hashed_ngan.path;
  };

  users.users.root.hashedPasswordFile = config.sops.secrets.hashed_ngan.path;

  # Passwordless rebuilds
  security.sudo.extraRules = [
    {
      users = [ "ngan" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /var/log/nixos-rebuild 0755 ngan users - -"
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.sharedModules = [ ./home/common.nix ];
  home-manager.users."ngan" = import ./home/ngan.nix;
}
