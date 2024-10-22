{ pkgs, modulesPath, config, lib, ... }:

{

  imports = [
    ./modules/installer/cd-dvd/installation-cd-minimal.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  environment.etc."setup.sh".source = ./setup.sh;
  environment.etc."setup.sh".mode = "0755";

  environment.etc."config.nix".source = ./configuration.nix;

  environment.etc."packages".source = ./packages;
}
