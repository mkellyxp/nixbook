{ config, pkgs, ... }:
let
  nixChannel = "https://nixos.org/channels/nixos-24.11"; 

  ## Notify Users Script
  notifyUsersScript = pkgs.writeScript "notify-users.sh" ''
    set -eu

    export PATH="${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:${pkgs.flatpak}/bin:${pkgs.sudo}/bin:${pkgs.libnotify}/bin:$PATH"

    title="$1"
    body="$2"

    users=$(loginctl list-sessions --no-legend | awk '{print $1}' | while read session; do
      loginctl show-session "$session" -p Name | cut -d'=' -f2
    done | sort -u)

    for user in $users; do
      ${pkgs.sudo}/bin/sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$user")/bus" \
        ${pkgs.libnotify}/bin/notify-send "$title" "$body"
    done
  '';

  ## Update Git and Channel Script
  updateGitScript = pkgs.writeScript "update-git.sh" ''
    set -eu

    export PATH="${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.nixos-rebuild}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:${pkgs.flatpak}/bin:$PATH"
    
    # Update nixbook configs
    git -C /etc/nixbook reset --hard
    git -C /etc/nixbook clean -fd
    git -C /etc/nixbook pull --rebase

    currentChannel=$(nix-channel --list | grep '^nixos' | awk '{print $2}')
    targetChannel="${nixChannel}"

    if [ "$currentChannel" != "$targetChannel" ]; then
      nix-channel --add "$targetChannel" nixos
      nix-channel --update
    fi
  '';
in
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
    gnugrep
    sudo
    gnome-software
    gnome-calculator
    gnome-calendar
    gnome-screenshot
    flatpak
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    system-config-printer
  ];

  services.flatpak.enable = true;

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 30d";
  };
  
  # Auto update config, flatpak and channel
  systemd.timers."auto-update-config" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Tue..Sun";
      Persistent = true;
      Unit = "auto-update-config.service";
    };
  };

  systemd.services."auto-update-config" = {
    path = with pkgs; [
      git
      nix
      gnugrep
      gawk
      util-linux
      coreutils-full
      flatpak
    ];

    script = ''
      set -eu

      ${updateGitScript}

      # Flatpak Updates
      nice -n 19 ionice -c 3 flatpak update --noninteractive --assumeyes
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    after = [ "network-online.target" "graphical.target" ];
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
    path = with pkgs; [
      git
      nixos-rebuild
      nix
      systemd
      util-linux
      coreutils-full
      flatpak
    ];
  
    script = ''
      set -eu
      export NIX_PATH="nixpkgs=${pkgs.path} nixos-config=/etc/nixos/configuration.nix"

      ${updateGitScript}

      ${notifyUsersScript} "Starting System Updates" "System updates are installing in the background.  You can continue to use your computer while these are running."
            
      nice -n 19 ionice -c 3 nixos-rebuild boot --upgrade

      # Fix for zoom flatpak
      flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom

      ${notifyUsersScript} "System Updates Complete" "Updates are complete!  Simply reboot the computer whenever is convenient to apply updates."
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
  };

  # Notify Test
  systemd.timers."notify-test" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      # OnCalendar = "*:*";
      OnCalendar = "daily";
      Persistent = true;
      Unit = "notify-test.service";
    };
  };
  
}

# Notes
#
# To reverse zoom flatpak fix:
#   flatpak override --unset-env=ZYPAK_ZYGOTE_STRATEGY_SPAWN us.zoom.Zoom
