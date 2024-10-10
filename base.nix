{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    git
    google-chrome
    libnotify
    libreoffice
    gnome.gnome-software

    # For Mike.. remove later
    htop
    helix
    xclip
    lazygit
  ];

  services.flatpak.enable = true;
  ## flatpak update --noninteractive --assumeyes

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-24.05";
  # system.autoUpgrade.schedule = "daily";
}
