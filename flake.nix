{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    nixcord.url = "github:4evy/nixcord";
    fcitx5-lotus.url = "github:LotusInputMethod/fcitx5-lotus";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix,  ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
	./disko.nix
	./preservation.nix
        ./configuration.nix
        home-manager.nixosModules.home-manager
	sops-nix.nixosModules.sops
	inputs.disko.nixosModules.disko
	inputs.preservation.nixosModules.default
	inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
      ];
    };
  };
}
