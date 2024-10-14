{ config, pkgs, ... }:
{
  # testing
  zramSwap.enable = true;

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
  ];

  services.flatpak.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.operation = "boot";
  system.autoUpgrade.dates = "Mon 04:40";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-24.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  systemd.timers."auto-update-config" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnCalendar = "daily";
      Unit = "auto-update-config.service";
    };
  };

  systemd.services."auto-update-config" = {
    script = ''
      set -eu
      ${pkgs.git}/bin/git -C /etc/nixbook pull
      ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  };
}
