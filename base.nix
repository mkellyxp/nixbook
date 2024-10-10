
{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  xdg.portal.enable = true;

  environment.systemPackages = with pkgs; [
    git
    google-chrome
    libnotify
    libreoffice
    gnome.gnome-software

    # For Mike.. remove later
    htop
    helix
    xclip
    lazygit
  ];

  services.flatpak.enable = true;

  systemd.timers."auto-updater" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "auto-updater.service";
        Persistent = true;
        AccuracySec = "1month";
      };
  };


  systemd.services."auto-updater" = {
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/touch "/home/user/$(date +'%Y%m%d%H%M%S').txt"

      ${pkgs.nix}/bin/nix-channel --update
      # ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --upgrade
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  };





}
