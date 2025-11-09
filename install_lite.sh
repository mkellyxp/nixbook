echo "This will delete ALL local files and convert this machine to a Nixbook Lite!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Installing NixBook Lite..."

  # Set up local files
  source ~/.config/user-dirs.dirs
  cp ~/.config/user-dirs.{dirs,locale} /tmp/
  rm -rf ~/* && rm -rf ~/.*
  mkdir $XDG_DESKTOP_DIR
  mkdir $XDG_DOCUMENTS_DIR
  mkdir $XDG_DOWNLOAD_DIR
  mkdir $XDG_MUSIC_DIR
  mkdir $XDG_PICTURES_DIR
  mkdir $XDG_PUBLICSHARE_DIR
  mkdir $XDG_TEMPLATES_DIR
  mkdir $XDG_VIDEOS_DIR
  mkdir ~/.local
  mkdir ~/.local/share
  cp -R /etc/nixbook/config/config_lite/* ~/.config
  mv /tmp/user-dirs.{dirs,locale} ~/.config/
  cp /etc/nixbook/config/desktop_lite/* $XDG_DESKTOP_DIR/
  cp -R /etc/nixbook/config/applications_lite/* ~/.local/share/applications

  # Add Nixbook config and rebuild
  sudo sed -i '/hardware-configuration\.nix/a\      /etc/nixbook/base_lite.nix' /etc/nixos/configuration.nix
  sudo nixos-rebuild switch

  # Lite has no flathub to save space
  
  reboot
else
  echo "Nixbook Lite Install Cancelled!"
fi

