
{ config, pkgs, ... }:
let
  nixChannel = "https://nixos.org/channels/nixos-24.11"; 
in
{
  zramSwap.enable = true;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  systemd.services."NetworkManager-wait-online".enable = true;

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
    gnome-calculator
    gnome-calendar
    gnome-screenshot
    system-config-printer
  ];

  nix.gc = {
    automatic = true;
    dates = "Mon 3:40";
    options = "--delete-older-than 14d";
  };

  # Auto update config, channel
  systemd.timers."auto-update-config" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
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
    ];
  
    script = ''
      set -eu

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
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "auto-upgrade.service";
    };
  };

  systemd.services."auto-upgrade" = {
    path = with pkgs; [
      nixos-rebuild
      nix
      systemd
      util-linux
      coreutils-full
    ];
  
    script = ''
      set -eu
      export NIX_PATH="nixpkgs=${pkgs.path} nixos-config=/etc/nixos/configuration.nix"
      
      systemctl start auto-update-config.service
      nice -n 19 ionice -c 3 nixos-rebuild boot --upgrade
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
