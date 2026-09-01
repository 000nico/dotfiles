# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ==========================================
  # Bootloader & Kernel
  # ==========================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==========================================
  # Display Manager & Desktop (Niri WM)
  # ==========================================
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # ==========================================
  # Networking & Hostname
  # ==========================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ==========================================
  # Time & Localization
  # ==========================================
  time.timeZone = "America/Argentina/Buenos_Aires";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_AR.UTF-8";
    LC_IDENTIFICATION = "es_AR.UTF-8";
    LC_MEASUREMENT = "es_AR.UTF-8";
    LC_MONETARY = "es_AR.UTF-8";
    LC_NAME = "es_AR.UTF-8";
    LC_NUMERIC = "es_AR.UTF-8";
    LC_PAPER = "es_AR.UTF-8";
    LC_TELEPHONE = "es_AR.UTF-8";
    LC_TIME = "es_AR.UTF-8";
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ==========================================
  # Audio (PipeWire) & Bluetooth
  # ==========================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ==========================================
  # Nix Settings & Flakes
  # ==========================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nixpkgs.config.allowUnfree = true;

  # ==========================================
  # Shell & User Configuration
  # ==========================================
  programs.zsh.enable = true;

  users.users."nico" = {
    isNormalUser = true;
    description = "nico";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
  };

  # ==========================================
  # Fonts
  # ==========================================
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ==========================================
  # System Packages
  # ==========================================
  environment.systemPackages = with pkgs; [
    # Terminal & Shell
    kitty
    zsh
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-autocomplete
    fzf
    eza
    bat
    fastfetch
    btop
    cava
    yazi
    ripgrep
    fd
    unzip
    tree-sitter
    shfmt
    stylua

    # Development Tools & Compilers
    gcc
    cargo
    rustc
    git
    neovim
    vscodium
    jetbrains.idea

    # Applications
    firefox
    librewolf
    vesktop
    nautilus

    # Wayland & Desktop Utilities
    waybar
    wofi
    fuzzel
    mako
    libnotify
    swaybg
    grim
    slurp
    satty
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    pavucontrol
    networkmanagerapplet
    xdg-utils
    dconf
  ];

  # ==========================================
  # Security & Polkit
  # ==========================================
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # System state version
  system.stateVersion = "26.05";
}
