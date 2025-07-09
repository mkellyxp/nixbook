{ config, pkgs, ... }:
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

      # Fix for gnome software nagging user
      ${pkgs.sudo}/bin/sudo -u "$user" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        ${pkgs.dconf}/bin/dconf write /org/gnome/software/flatpak-updates false || true

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
    dconf
    gnome-software
    gnome-calculator
    gnome-calendar
    gnome-screenshot
    flatpak
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    system-config-printer

    (makeDesktopItem {
      name = "zoommtg-handler";
      desktopName = "Zoom URI Handler";
      exec = "gtk-launch us.zoom.Zoom %u";
      mimeTypes = [ "x-scheme-handler/zoommtg" ];
      noDisplay = true;
      type = "Application";
    })
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
    script = ''
      set -eu

      ${updateGitScript}

      # Flatpak Updates
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
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
    script = ''
      set -eu
      export PATH=${pkgs.nixos-rebuild}/bin:${pkgs.nix}/bin:${pkgs.systemd}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:$PATH
      export NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos nixos-config=/etc/nixos/configuration.nix"

      ${updateGitScript}

      ${notifyUsersScript} "Starting System Updates" "System updates are installing in the background.  You can continue to use your computer while these are running."
            
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --upgrade

      # Fix for zoom flatpak
      ${pkgs.flatpak}/bin/flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom

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
  
}

# Notes
#
# To reverse zoom flatpak fix:
#   flatpak override --unset-env=ZYPAK_ZYGOTE_STRATEGY_SPAWN us.zoom.Zoom
