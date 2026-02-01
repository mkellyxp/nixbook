# Packages to support Nixbook Development
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    helix
    xclip
    nixfmt
  ];

  # VM guest additions to improve host-guest interaction
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;
  virtualisation.vmware.guest.enable = pkgs.stdenv.hostPlatform.isx86;
  # https://github.com/torvalds/linux/blob/00b827f0cffa50abb6773ad4c34f4cd909dae1c8/drivers/hv/Kconfig#L7-L8
  virtualisation.hypervGuest.enable =
    pkgs.stdenv.hostPlatform.isx86 || pkgs.stdenv.hostPlatform.isAarch64;
  services.xe-guest-utilities.enable = pkgs.stdenv.hostPlatform.isx86;
  # The VirtualBox guest additions rely on an out-of-tree kernel module
  # which lags behind kernel releases, potentially causing broken builds.
  virtualisation.virtualbox.guest.enable = false;

}

# To configure helix to use the nix formatter, put this in languages.toml
#
# [[language]]
# name = "nix"
# formatter = { command = "nixfmt" }
# auto-format = true
