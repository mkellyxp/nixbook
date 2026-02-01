# Common config used by the installer, Nixbook, and Nixbook Lite
{ pkgs, lib, ... }:

{
  imports = [ ./chromebook.nix ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

  # Plymouth boot splash screen - hides boot text for cleaner startup
  boot.plymouth.enable = true;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_level=3"
  ];

  # GRUB bootloader settings for silent boot (hides early kernel messages)
  boot.loader.grub.gfxpayloadBios = "keep";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.bluetooth.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Enable Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # For Chris at LUP :)
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Common Packages
  environment.systemPackages = with pkgs; [
    git
    firefox
    libnotify
    gawk
    sudo
    gnome-calculator
    gnome-calendar
    gnome-screenshot
    system-config-printer
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
    fontDir.enable = true;
  };

}

## NOTES ##
# To enable auto login for user, add this to your /etc/nixos/configuration.nix
#
# services.displayManager.autoLogin = {
#   enable = true;
#   user = "user";   #make "user" whatever your username is
# }
#
# To stop chrome from asking for a password anyway, copy desktop file from
# /var/lib/flatpak/exports/share/applications/ to ~/.local/share/applications
# and change Exec = to add in "--password-store=basic"
