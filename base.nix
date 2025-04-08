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
  ];

  services.flatpak.enable = true;

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    dates = "Mon 04:40";
    channel = nixChannel;
  };

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 30d";
  };

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

      # Update nixbook configs
      ${pkgs.git}/bin/git -C /etc/nixbook reset --hard
      ${pkgs.git}/bin/git -C /etc/nixbook clean -fd
      ${pkgs.git}/bin/git -C /etc/nixbook pull --rebase

      currentChannel=$(${pkgs.nix}/bin/nix-channel --list | ${pkgs.gnugrep}/bin/grep '^nixos' | ${pkgs.gawk}/bin/awk '{print $2}')
      targetChannel="${nixChannel}"

      echo "Current Channel is: $currentChannel"

      if [ "$currentChannel" != "$targetChannel" ]; then
        echo "Updating Nix channel to $targetChannel"
        ${pkgs.nix}/bin/nix-channel --add "$targetChannel" nixos
        ${pkgs.nix}/bin/nix-channel --update
      else
        echo "Nix channel is already set to $targetChannel"
      fi
      

      # Flatpak Updates
      ${pkgs.coreutils-full}/bin/nice -n 19 ${pkgs.util-linux}/bin/ionice -c 3 ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
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

## WIP Notes:
# 
# channel_url=$(nix-channel --list | awk '$1 == "nixos" { print $2 }')
# 
