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
  ];

  services.flatpak.enable = true;

  systemd.timers."hello-world" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "hello-world.service";
      };
  };

  systemd.services."hello-world" = {
    script = ''
      set -eu
      ${pkgs.libnotify}/bin/notify-send "Hello World"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
