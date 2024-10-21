{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }@attrs: {
    nixosConfigurations = {
      dell-3040-client = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
	modules = [
	  ./hardware/dell-3040.nix
	  ./machines/client.nix
	];
      };
    };
  };
}  
   
