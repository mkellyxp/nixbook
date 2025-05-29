# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixbook;
in
lib.mkIf cfg.enable {

  imports =
    lib.optionnal cfg.fullVersion [
      ./base.nix
    ]
    ++ lib.optionnal (!cfg.fullVersion) [ ./base_lite.nix ];

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
    # Opinionated: disable channels
    channel.enable = false;
  };

  networking.hostName = cfg.hostName;
  services.networkmanager.enable = true;

  users.users = builtins.mapAttrs (name: value: {
    isNormalUser = lib.mkDefault true;
    description = lib.mkDefault value.fullName;
    extraGroups =
      lib.mkDefault [
        "networkmanager"
        "audio"
      ]
      ++ lib.optionals value.admin [ "wheel" ]
      ++ lib.optionals (lib.hasAttr "groups" value) value.groups;
  }) cfg.users;

  # Disable SSH
  services.openssh = {
    enable = false;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
    };
  };
}
