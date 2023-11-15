{ config, pkgs, ... }:

# allow unstable packages
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-22bb5904-0453-478a-b2a0-2f9192b5c485".device = "/dev/disk/by-uuid/22bb5904-0453-478a-b2a0-2f9192b5c485";

  # networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # location
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # xserver
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users.thor = {
    isNormalUser = true;
    description = "thor";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      unstable.thunderbird
      unstable.keepassxc
      unstable.syncthing
      unstable.brave
      unstable.signal-desktop
      unstable.element-desktop
    ];
  };

  # allow unfree and unstable packages
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # packages installed in system profile
  environment.systemPackages = with pkgs; [
    # system tools
    git
    htop
    vim 
    wget
    home-manager
    # development
    docker-compose
    unstable.poetry
    unstable.python311
    unstable.vscode
    # privacy
    unstable.mullvad-vpn
    # gnome
    gnomeExtensions.appindicator 
    gnome.gnome-tweaks
    gnome.dconf-editor
    dconf2nix
  ];

  # List services that you want to enable:
  services = {
  
    syncthing = { 
      enable = true;
      user = "thor";
      dataDir = "/home/thor/";
    };
    mullvad-vpn.enable=true;
  };

  # home-manager
  home-manager.users.thor = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    programs.bash.enable = true;
    imports = [ ./dconf.nix ];
    home.stateVersion = "23.05";
  };

  # general settings
  virtualisation.docker.enable = true;
  system.stateVersion = "23.05"; 
}
