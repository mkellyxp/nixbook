# This is a script that serves as an escape hatch to fix any issues that can prop up and break automatic updates
# It is purposely in a script in case we need to fix something that is breaking nix rebuilds

# Fixes rare, but annoying issue with flatpak updates failing due to corrupt files.
sudo flatpak repair --system
sudo flatpak update -y
