{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixChannel = "https://nixos.org/channels/nixos-25.05";

  ## Notify Users Script
  notifyUsersScript = pkgs.writeScript "notify-users.sh" ''
    set -eu

    title="$1"
    body="$2"

    users=$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}' | while read session; do
      loginctl show-session "$session" -p Name | cut -d'=' -f2
    done | sort -u)

    for user in $users; do
      [ -n "$user" ] || continue
      uid=$(id -u "$user") || continue
      [ -S "/run/user/$uid/bus" ] || continue

      # Send notification
      ${pkgs.sudo}/bin/sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        ${pkgs.libnotify}/bin/notify-send "$title" "$body" || true

    done

  '';

  ## Update Git and Channel Script
  updateGitScript = pkgs.writeScript "update-git.sh" ''
    set -eu

    # Update nixbook configs
    ${pkgs.git}/bin/git -C /etc/nixbook reset --hard
    ${pkgs.git}/bin/git -C /etc/nixbook clean -fd
    ${pkgs.git}/bin/git -C /etc/nixbook pull --rebase

    currentChannel=$(${pkgs.nix}/bin/nix-channel --list | ${pkgs.gnugrep}/bin/grep '^nixos' | ${pkgs.gawk}/bin/awk '{print $2}')
    targetChannel="${nixChannel}"

    if [ "$currentChannel" != "$targetChannel" ]; then
      ${pkgs.nix}/bin/nix-channel --add "$targetChannel" nixos
      ${pkgs.nix}/bin/nix-channel --update
    fi
  '';
in
{
  imports = [
    ./common.nix
    ./installed.nix
  ];

  zramSwap.memoryPercent = 100;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 14d";
  };

  # Auto update config and channel
  systemd.timers."auto-update-config" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Tue..Sun";
      Persistent = true;
      Unit = "auto-update-config.service";
    };
  };

  systemd.services."auto-update-config" = {
    script = ''
      set -eu

      ${updateGitScript}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
      CPUWeight = "20";
      IOWeight = "20";
      MemoryHigh = "500M";
    };

    after = [
      "network-online.target"
      "graphical.target"
    ];
    wants = [ "network-online.target" ];
  };

  # Auto Upgrade NixOS
  systemd.timers."auto-upgrade" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon";
      Persistent = true;
      Unit = "auto-upgrade.service";
    };
  };

  systemd.services."auto-upgrade" = {
    script = ''
      set -eu
      export PATH=${pkgs.nixos-rebuild}/bin:${pkgs.nix}/bin:${pkgs.systemd}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:$PATH
      export NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos nixos-config=/etc/nixos/configuration.nix"

      ${updateGitScript}

      ${notifyUsersScript} "Starting System Updates" "System updates are installing in the background.  You can continue to use your computer while these are running."
            
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --upgrade

      ${notifyUsersScript} "System Updates Complete" "Updates are complete!  Simply reboot the computer whenever is convenient to apply updates."
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
      CPUWeight = "20";
      IOWeight = "20";
      MemoryHigh = "500M";
    };

    after = [
      "network-online.target"
      "graphical.target"
    ];
    wants = [ "network-online.target" ];
  };
}
