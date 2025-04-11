{ config, pkgs, ... }:
let
  nixChannel = "https://nixos.org/channels/nixos-24.11"; 
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
      OnBootSec = "5m";
      OnCalendar = "daily";
      Unit = "auto-update-config.service";
    };
  };

  systemd.services."auto-update-config" = {
    script = ''
      set -eu
      export PATH=${pkgs.git}/bin:${pkgs.nix}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:${pkgs.flatpak}/bin:$PATH

      # Update nixbook configs
      git -C /etc/nixbook reset --hard
      git -C /etc/nixbook clean -fd
      git -C /etc/nixbook pull --rebase

      currentChannel=$(nix-channel --list | grep '^nixos' | awk '{print $2}')
      targetChannel="${nixChannel}"

      echo "Current Channel is: $currentChannel"

      if [ "$currentChannel" != "$targetChannel" ]; then
        echo "Updating Nix channel to $targetChannel"
        nix-channel --add "$targetChannel" nixos
        nix-channel --update
      else
        echo "Nix channel is already set to $targetChannel"
      fi
      
      # Flatpak Updates
      nice -n 19 ionice -c 3 flatpak update --noninteractive --assumeyes
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
  
    wantedBy = [ "default.target" ];
  };

  # Auto Upgrade NixOS
  systemd.timers."auto-upgrade" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnCalendar = "weekly";
      Unit = "auto-upgrade.service";
    };
  };

  systemd.services."auto-upgrade" = {
    script = ''
      set -eu
      export PATH=${pkgs.nixos-rebuild}/bin:${pkgs.nix}/bin:${pkgs.systemd}/bin:${pkgs.util-linux}/bin:${pkgs.coreutils-full}/bin:${pkgs.flatpak}/bin:$PATH
      export NIX_PATH="nixpkgs=${pkgs.path} nixos-config=/etc/nixos/configuration.nix"
      
      systemctl start auto-update-config.service
      nice -n 19 ionice -c 3 nixos-rebuild boot --upgrade

      # Fix for zoom flatpak
      flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    after = [ "network-online.target" "graphical.target" ];
    wants = [ "network-online.target" ];
  
    wantedBy = [ "default.target" ];
  };
}

# Notes
#
# To reverse zoom flatpak fix:
#   flatpak override --unset-env=ZYPAK_ZYGOTE_STRATEGY_SPAWN us.zoom.Zoom
