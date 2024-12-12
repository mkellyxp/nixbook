
{ config, pkgs, ... }:
{
  zramSwap.enable = true;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    git
    firefox
    libnotify
    gawk
    sudo
    gnome.gnome-calculator
    gnome.gnome-calendar
    gnome.gnome-screenshot
  ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.operation = "boot";
  system.autoUpgrade.dates = "Mon 04:40";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-24.05";

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    dates = "Mon 04:40";
    channel = "https://nixos.org/channels/nixos-24.05";
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 14d";
  };

  systemd.services."auto-update-config" = {
    script = ''
      set -eu
      ${pkgs.git}/bin/git -C /etc/nixbook pull

      uptime_seconds=$(cat /proc/uptime | ${pkgs.gawk}/bin/awk '{print $1}' | cut -d. -f1)
      days=$((uptime_seconds / 86400))

      if [ "$days" -gt 25 ]; then
        sessions=$(loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}')
        for session in $sessions; do
          user=$(loginctl show-session "$session" -p Name | cut -d'=' -f2)
          ${pkgs.sudo}/bin/sudo -u "$user" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$user")/bus" ${pkgs.libnotify}/bin/notify-send "Please reboot to apply updates" "Updates have already been downloaded and installed.  Simply reboot to apply these updates."
        done
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  };
}
