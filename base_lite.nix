{ config, pkgs, ... }:
{
  # testing
  zramSwap.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = (with pkgs; [
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
    geary
  ]);
  programs.dconf.enable = true;
  #programs.dconf.profiles.user.databases = [
  #  {
  #    settings = {
  #      "org/gnome/desktop/interface" = {
  #        color-scheme = "prefer-dark";
  #      };
  #      "org/gnome/shell" = {
  #        favorite-apps = [
  #          "firefox.desktop"
  #          "org.gnome.Nautilus.desktop"
  #        ];
  #        disable-user-extensions = false;
  #        enabled-extensions = [
  #          "dash-to-panel@jederose9.github.com"
  #          "caffeine@patapon.info"
  #          "clipboard-indicator@tudmotu.com"
  #        ];
  #      };
  #    };
  #  }
  #];

  environment.systemPackages = with pkgs; [
    git
    firefox
    libnotify
    gnome.gnome-tweaks
    # Gnome Extensions
    gnomeExtensions.dash-to-panel
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.arc-menu
  ];

  services.flatpak.enable = false;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.operation = "boot";
  system.autoUpgrade.dates = "Mon 04:40";
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-24.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  #systemd.timers."auto-update-config" = {
  #wantedBy = [ "timers.target" ];
  #  timerConfig = {
  #    OnBootSec = "1m";
  #    OnCalendar = "daily";
  #    Unit = "auto-update-config.service";
  #  };
  #};

  #systemd.services."auto-update-config" = {
  #  script = ''
  #    set -eu
  #    ${pkgs.git}/bin/git -C /etc/nixbook pull
  #    ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "root";
  #  };
  #  wantedBy = [ "multi-user.target" ]; # Ensure the service starts after rebuild
  #};
}
