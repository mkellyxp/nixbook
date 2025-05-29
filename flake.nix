{
  description = "Convert your old computer (even chromebook) to a user friendly, lightweight, durable, and auto updating operating system build on top of NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
    }:
    flake-parts.lib.eachDefaultSystem (system: {
      nixosModules.default =
        { ... }:
        {
          imports = [
            ./configuration.nix
            ./options.nix
          ];
        };

      apps.install = { };
      apps.update = { };
      apps.powerwash = { };
    });
}
