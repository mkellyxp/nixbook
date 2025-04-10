echo "This will update your Nixbook and shut down";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Updating Nixbook..."

  sudo systemctl start auto-update-config.service;

  # Free up space before updates
  nix-collect-garbage --delete-older-than 14d

  # get the updates
  sudo nixos-rebuild boot --upgrade

  # free up a little more space with hard links
  nix-store --optimise

  systemctl poweroff
else
  echo "Update Cancelled!"
fi
