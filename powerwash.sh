read -p "This will delete ALL local files and reset this Nixbook!\nDo you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  # Get latest nixbook code
  sudo git -C /etc/nixbook pull

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild boot --upgrade

  # Erase data and set up home directory again
  rm -rf ~/
  mkdir ~/Desktop
  mkdir ~/Documents
  mkdir ~/Downloads
  cp -R /etc/nixbook/config/config ~/.config
  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
