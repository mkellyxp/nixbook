echo "This will update your Nixbook and reboot";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Updating Nixbook..."
  sudo systemctl stop auto-upgrade.service

  /etc/nixbook/channel.sh
  /etc/nixbook/repair.sh

  sudo systemctl start auto-update-config.service;

  # Free up space before updates
  nix-collect-garbage --delete-older-than 30d

  # get the updates
  sudo nixos-rebuild boot --upgrade

  reboot
else
  echo "Update Cancelled!"
fi
