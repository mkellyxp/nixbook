
echo "This will delete ALL local files and reset this Nixbook Lite!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook Lite..."

  sudo systemctl start auto-update-config.service;
  
  # Erase data and set up home directory again
  rm -rf ~/
  mkdir ~/Desktop
  mkdir ~/Documents
  mkdir ~/Downloads
  mkdir ~/Pictures
  mkdir ~/.local
  mkdir ~/.local/share
  cp -R /etc/nixbook/config/config_lite ~/.config
  cp /etc/nixbook/config/desktop_lite/* ~/Desktop/
  cp -R /etc/nixbook/config/applications_lite ~/.local/share/applications

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild boot --upgrade
  sudo nixos-rebuild list-generations
  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
