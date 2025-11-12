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

  ## Install Flatpak Apps Script
  installFlatpakAppsScript = pkgs.writeScript "install-flatpak-apps.sh" ''
    set -eu

    if ${pkgs.flatpak}/bin/flatpak list --app | ${pkgs.gnugrep}/bin/grep -q "org.libreoffice.LibreOffice"; then
      echo "Flatpaks already installed"
    else


      # Install Flatpak applications
      ${notifyUsersScript} "Installing Google Chrome" "Please wait while we install Google Chrome..."
      ${pkgs.flatpak}/bin/flatpak install flathub com.google.Chrome -y

      ${notifyUsersScript} "Installing Zoom" "Please wait while we install Zoom..."
      ${pkgs.flatpak}/bin/flatpak install flathub us.zoom.Zoom -y

      ${notifyUsersScript} "Installing LibreOffice" "Please wait while we install LibreOffice..."
      ${pkgs.flatpak}/bin/flatpak install flathub org.libreoffice.LibreOffice -y

      # Fix for zoom flatpak
      ${pkgs.flatpak}/bin/flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom
      ${pkgs.flatpak}/bin/flatpak install flathub org.gtk.Gtk3theme.Mint-Y-Dark-Blue -y


      users=$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend | ${pkgs.gawk}/bin/awk '{print $1}' | while read session; do
        loginctl show-session "$session" -p Name | cut -d'=' -f2
      done | sort -u)

      for user in $users; do
        [ -n "$user" ] || continue
        uid=$(id -u "$user") || continue
        [ -S "/run/user/$uid/bus" ] || continue

        cp /etc/nixbook/config/flatpak_links/* /home/$user/Desktop/
        chown $user /home/$user/Desktop/*
      
        ${notifyUsersScript} "Installing Applications Complete" "Please Log out or restart to start using Nixbook and it's applications!"
      done
    fi

  '';
in
{
  imports = [
    ./common.nix
    ./installed.nix
  ];

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  xdg.portal.enable = true;
  environment.systemPackages = with pkgs; [
    gnugrep
    dconf
    gnome-software
    flatpak
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome

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

  # Install Flatpak Applications Service
  systemd.services."install-flatpak-apps" = {
    script = ''
      set -eu
      ${installFlatpakAppsScript}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
    };

    after = [
      "network-online.target"
      "flatpak-system-helper.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };

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
      ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
      CPUWeight = "20";
      IOWeight = "20";
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

      # Fix for zoom flatpak
      ${pkgs.flatpak}/bin/flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom

      ${notifyUsersScript} "System Updates Complete" "Updates are complete!  Simply reboot the computer whenever is convenient to apply updates."
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Restart = "on-failure";
      RestartSec = "30s";
      CPUWeight = "20";
      IOWeight = "20";
    };

    after = [
      "network-online.target"
      "graphical.target"
    ];
    wants = [ "network-online.target" ];
  };
}

# Notes
#
# To reverse zoom flatpak fix:
#   flatpak override --unset-env=ZYPAK_ZYGOTE_STRATEGY_SPAWN us.zoom.Zoom
