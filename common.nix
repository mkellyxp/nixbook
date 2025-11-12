# Common config used by the installer, Nixbook, and Nixbook Lite
{ pkgs, lib, ... }:

{
  imports = [
    ./chromebook.nix
  ];

  zramSwap.enable = true;

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
