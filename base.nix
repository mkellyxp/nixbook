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
      export PATH=${pkgs.nixos-rebuild}/bin:${pkgs.nix}/bin:${pkgs.systemd}/bin:$PATH
      export NIX_PATH="nixpkgs=${pkgs.path} nixos-config=/etc/nixos/configuration.nix"
      
      systemctl start auto-update-config.service
      nixos-rebuild boot --upgrade
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
