# Packages to support Nixbook Development
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    helix
    xclip
    nixfmt
  ];
}

# To configure helix to use the nix formatter, put this in languages.toml
#
# [[language]]
# name = "nix"
# formatter = { command = "nixfmt" }
# auto-format = true
