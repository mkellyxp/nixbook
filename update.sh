echo "This will update your Nixbook and reboot";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Updating Nixbook..."

  # Download the latest nixbook changes
  sudo git -C /etc/nixbook reset --hard
  sudo git -C /etc/nixbook clean -fd
  sudo git -C /etc/nixbook pull

  # Update the nixos nix-channel to be the same as config.system.autoUpgrade.channel in base.nix or base_lite.nix
  AUTOUPDATE_CHANNEL="$(sudo nix-instantiate --eval '<nixpkgs/nixos>' -A config.system.autoUpgrade.channel | tr -d '"')"
  sudo nix-channel --add "${AUTOUPDATE_CHANNEL}" nixos

  # Free up space before updates
  nix-collect-garbage --delete-older-than 30d

  # get the updates
  flatpak update -y
  sudo nixos-rebuild boot --upgrade

  # free up a little more space with hard links
  nix-store --optimise

  reboot
else
  echo "Update Cancelled!"
fi
