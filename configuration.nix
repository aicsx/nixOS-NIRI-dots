# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "axos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "it_IT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ax" = {
    isNormalUser = true;
    description = "ax";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true; 
  
  # Abilita esplicitamente il caricamento di tutto il firmware di terze parti
  hardware.enableAllFirmware = true;

  # 1. Dice a NixOS di compilare il pacchetto per il kernel attualmente in uso
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ./mt7630e.nix { })
  ];

  # 2. Forza il caricamento del modulo mt76xx all'avvio del sistema
  boot.kernelModules = [ "mt76xx" "bluetooth" "btusb" ];

  # Attiva il bluetooth
  hardware.bluetooth = {
 	enable = true;
 	powerOnBoot = true;
  };
  
  services.blueman.enable = true;

  # BASH profile stile gentoo
  programs.bash.promptInit = ''
  # Stile Gentoo: colore diverso per utente (verde) e root (rosso)
  if [ $EUID -eq 0 ]; then
    # Colore rosso per root
    PS1='\[\033[01;31m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
  else
    # Colore verde per utente normale
    PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
  fi
  '';
  
  environment.shellAliases = {
    ls = "eza --icons";
    ll = "eza -l --icons";
    la = "eza -a --icons";
    lla = "eza -la --icons";
  };
   
  # TPM DISABLE
  systemd.tpm2.enable = false;
  systemd.units."dev/tpmrm0.device".enable = false;
  security.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;
  
  # FONTS
  fonts.packages = with pkgs; [
	noto-fonts
	font-awesome
	nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only  # Questo pacchetto garantisce la lettura di Pacman e Fantasmini
  ];

  # Sezione aggiunta ------
  # ABILITA NIRI come WM 
  programs.niri.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   ncdu
   net-tools
   pciutils
   usbutils
   fastfetch
   htop
   bat
   wget
   git
   bash-completion
   # DI SEGUITO PER NIRI ------
   alacritty
   ghostty
   waybar
   thunar
   thunar-archive-plugin
   thunar-volman
   superfile
   librewolf
   google-chrome
   unzip
   p7zip
   gnutar
   gzip
   file-roller
   brightnessctl
   gnome-calendar
   adwaita-icon-theme
   papirus-icon-theme
   nwg-look
   bibata-cursors
   xdg-user-dirs
   wlogout
   librsvg
   btop
   swaybg
   pavucontrol
   rofi
   eza
   mpv
   loupe
   neovim
   weechat
  ];

  programs.hyprlock.enable = true;
  programs.bash.completion.enable = true;

  # Abilita cestino in thunar 
  services.gvfs.enable = true;
  # (Opzionale) Salva le preferenze di Thunar e abilita le miniature delle immagini
  programs.xfconf.enable = true;
  services.tumbler.enable = true; 

  # abilita synch calendario 
  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.evolution-data-server.enable = true;

  # DBUS
  services.dbus.enable = true;

  # DRIVER INTEL HD 5500 -------
  hardware.graphics = {
  	enable = true;
  	extraPackages= with pkgs; [
		intel-media-driver
		intel-vaapi-driver
	];
  };

  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [
	"i915.enable_dc=0"
	"i915.enable_fbc=0"
        "quiet"
	"splash"
	"loglevel=3"
  ];

  # AUDIO, SERVIZI ESSENZIALI ------
  # Abilita pipewire su wayland
  services.pipewire = {
	enable = true;
	alsa.enable = true;
	pulse.enable = true;
  };

  # Portali XDG (servono a niri per gli screenshot e per far aprire i file alle app) -----
  xdg.portal = {
	enable = true;
	extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
	config.common.default = [ "gnome" ];
  };

  # Abilita Xwayland per far girare le app X11 su Niri ------
  programs.xwayland.enable = true;

  # Abilita greetd con interfaccia tuigreet come "Login manager" ------
  services.greetd = {
	enable = true;
	settings = {
	  default_session = {
	  command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'sh -c \"${config.programs.niri.package}/bin/niri-session 2>/dev/null\"'";
	user = "greeter";
	};
     };
  };

 # consigliato per i log di systemd con niri
 systemd.user.services.niri.enableDefaultPath = false;

  system.stateVersion = "26.05"; # Did you read the comment?

}
