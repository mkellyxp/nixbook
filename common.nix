# Common config used by the installer, Nixbook, and Nixbook Lite
{ pkgs, lib, ... }:

{
  imports = [ ./chromebook.nix ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;

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

  # For Chris at LUP :)
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Better VM Support
  services.spice-vdagentd.enable = true;

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
