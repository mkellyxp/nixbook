echo "This will delete ALL local files and convert this machine to a Nixbook Lite!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Installing NixBook Lite..."

  # Set up local files
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

  # Add Nixbook config and rebuild
  sudo sed -i '/hardware-configuration\.nix/a\      /etc/nixbook/base_lite.nix' /etc/nixos/configuration.nix
  sudo nixos-rebuild switch

  # Lite has no flathub to save space
  
  reboot
else
  echo "Nixbook Lite Install Cancelled!"
fi

