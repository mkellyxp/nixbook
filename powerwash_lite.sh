
echo "This will delete ALL local files and reset this Nixbook Lite!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook Lite..."

  sudo systemctl start auto-update-config.service;
  
  # Erase data and set up home directory again
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
  cp -R /etc/nixbook/config/applications_lite ~/.local/share/applications

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild boot --upgrade
  sudo nixos-rebuild list-generations
  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
