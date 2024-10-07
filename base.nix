
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
    dbus
    libreoffice
    gnome.gnome-software

    # For Mike.. remove later
    htop
    helix
    xclip
  ];

  services.flatpak.enable = true;

  systemd.timers."auto-updater" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "auto-updater.service";
        Persistent = true;
        AccuracySec = "1month";
      };
  };

  systemd.services."auto-updater" = {
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/touch "/home/user/$(date +'%Y%m%d%H%M%S').txt"

      # Get the active user and their DBus session address
      USER=$(loginctl list-users --no-legend | ${pkgs.gawk}/bin/awk '{print $1}' | head -n1)
      USER_ID=$(id -u $USER)
      DBUS_SESSION=$(loginctl show-user $USER --property=Display --value)
      DISPLAY=$(loginctl show-session $DBUS_SESSION --property=Display --value)
      XDG_RUNTIME_DIR="/run/user/$USER_ID"

      # Send a notification to the user
      ${pkgs.sudo}/bin/sudo -u $USER DISPLAY=$DISPLAY DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus \
        ${pkgs.libnotify}/bin/notify-send "Hello World" "This is your notification from the auto-updater service"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  };

}
