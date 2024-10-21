{ config, lib, pkgs, ... }:

let
  utc-foxdot = import ./packages/FoxDot/default.nix {
    inherit (pkgs) lib stdenv fetchFromGitHub tkinter supercollider;
    buildPythonPackage = pkgs.python3Packages.buildPythonPackage;
  };
in
{
  networking.hostName = "nixos";

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Timezone and locale settings
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console settings
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
    vscode
    emacs
    android-studio
    android-studio-tools
    google-chrome
    utc-foxdot
    supercollider
    python3
    git
    vscode
    gh
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # State version
  system.stateVersion = "24.05";

  # User account configuration
  users.users.nixos = {
    description = "NixOS";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
    packages = with pkgs; [ ];
    hashedPassword = null;
  };

  # Hardware settings
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Boot and filesystem configuration
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Networking settings
  networking.useDHCP = lib.mkDefault true;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Plasma desktop configuration
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };

  # Printing services
  services.printing.enable = true; # Enables printing

  # Import hardware configuration
  imports = [ ./hardware-configuration.nix ];
}
