{
  lib,
  ...
}:
{
  options.nixbook = {
    enable = lib.mkEnableOption "enable Nixbook.";
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the computer. Should be equal to the hostName used after 'nixosConfigurations' in flake.";
      default = "nixbook";
    };
    fullVersion = lib.mkEnableOption "install extra softwares by default.";
    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            admin = lib.mkEnableOption "Whether to give administrator rights to the user.";
            fullName = lib.mkOption { type = lib.types.str; };
            groups = lib.mkOption {
              type = lib.types.listOf (lib.types.str);
              default = [ ];
              description = "Extra groups to give to the user.";
            };
          };
        }
      );
    };
  };
}
