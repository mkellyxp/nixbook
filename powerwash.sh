echo "This will delete ALL local files and reset this Nixbook!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  # Get latest nixbook code
  sudo git -C /etc/nixbook pull

  # Erase data and set up home directory again
  rm -rf ~/
  mkdir ~/Desktop
  mkdir ~/Documents
  mkdir ~/Downloads
  mkdir ~/Pictures
  cp -R /etc/nixbook/config/config ~/.config
  sudo rm -r /var/lib/flatpak/app

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild boot --upgrade
  sudo nixos-rebuild list-generations  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
