
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

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    dates = "Mon 04:40";
    channel = "https://nixos.org/channels/nixos-24.11";
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 14d";
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
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.git}/bin/git -C /etc/nixbook reset --hard
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.git}/bin/git -C /etc/nixbook clean -fd
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.git}/bin/git -C /etc/nixbook pull

      # Get the timestamp of the current generation
      last_gen_time=$(${pkgs.nix}/bin/nix-env --list-generations --profile /nix/var/nix/profiles/system | ${pkgs.gawk}/bin/awk 'END {print $2, $3}')
  
      # Convert the timestamp to seconds since epoch
      last_gen_sec=$(date -d "$last_gen_time" +%s)

      # Get the current time in seconds since epoch
      now=$(date +%s)

      # Calculate the difference in days
      days_since_last_gen=$((($now - $last_gen_sec) / 86400))

      if [ "$days_since_last_gen" -gt 25 ]; then
        sessions=$(loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}')
        for session in $sessions; do
          user=$(loginctl show-session "$session" -p Name | cut -d'=' -f2)
          ${pkgs.sudo}/bin/sudo -u "$user" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$user")/bus" ${pkgs.libnotify}/bin/notify-send "System has not been updated recently" "Please run Update and Reboot or Update and Shutdown from the Start Menu under Administration."
        done
      else
        uptime_seconds=$(cat /proc/uptime | ${pkgs.gawk}/bin/awk '{print $1}' | cut -d. -f1)
        days=$((uptime_seconds / 86400))

        if [ "$days" -gt 25 ]; then
          sessions=$(loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}')
          for session in $sessions; do
            user=$(loginctl show-session "$session" -p Name | cut -d'=' -f2)
            ${pkgs.sudo}/bin/sudo -u "$user" "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$user")/bus" ${pkgs.libnotify}/bin/notify-send "Please reboot to apply updates" "Updates have already been downloaded and installed.  Simply reboot to apply these updates."
          done
        fi
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  };
}
