echo "This will update your Nixbook and reboot";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Updating Nixbook..."
  sudo nixos-rebuild boot --upgrade
  flatpak update -y
  reboot
else
  echo "Update Cancelled!"
fi
