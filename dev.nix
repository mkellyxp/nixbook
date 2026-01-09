# Packages to support Nixbook Development
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    helix
    xclip
    nixfmt
  ];
}
