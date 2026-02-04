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
  services.xserver.displayManager.lightdm.enable = lib.mkDefault true;
  services.xserver.desktopManager.cinnamon.enable = lib.mkDefault true;

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

  # VM guest additions to improve host-guest interaction
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;
  # https://github.com/torvalds/linux/blob/00b827f0cffa50abb6773ad4c34f4cd909dae1c8/drivers/hv/Kconfig#L7-L8
  virtualisation.hypervGuest.enable =
    pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isAarch64;
  services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
  # The VirtualBox guest additions rely on an out-of-tree kernel module
  # which lags behind kernel releases, potentially causing broken builds.
  virtualisation.virtualbox.guest.enable = false;

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
