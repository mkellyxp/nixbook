# This is a script that will run to keep channels synced up, and also serve as an escape hatch to fix any issues that can prop up and break automatic updates
# It is purposely in a script in case we need to fix something that is breaking nix rebuilds

# Fixes rare, but annoying issue with flatpak updates failing due to corrupt files.
sudo flatpak repair --system
sudo flatpak update
 
# Will make sure Nixbook is on the correct channel
currentChannel=$(${pkgs.nix}/bin/nix-channel --list | ${pkgs.gnugrep}/bin/grep '^nixos' | ${pkgs.gawk}/bin/awk '{print $2}')
targetChannel="https://nixos.org/channels/nixos-25.11"

if [ "$currentChannel" != "$targetChannel" ]; then
  ${pkgs.nix}/bin/nix-channel --add "$targetChannel" nixos
  ${pkgs.nix}/bin/nix-channel --update
fi
