echo "This will delete ALL local files and convert this machine to a Nixbook!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Installing NixBook..."

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
  cp -R /etc/nixbook/config/config/* ~/.config
  mv /tmp/user-dirs.{dirs,locale} ~/.config/
  cp /etc/nixbook/config/desktop/* $XDG_DESKTOP_DIR/
  cp -R /etc/nixbook/config/applications/* ~/.local/share/applications

  # The rest of the install should be hands off
  # Add Nixbook config and rebuild
  sudo sed -i '/hardware-configuration\.nix/a\      /etc/nixbook/base.nix' /etc/nixos/configuration.nix
  
  # Set up flathub repo while we have sudo
  nix-shell -p flatpak --run 'sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo'

  sudo nixos-rebuild switch

  # Add flathub and some apps
  flatpak install flathub com.google.Chrome -y
  flatpak install flathub us.zoom.Zoom -y
  flatpak install flathub org.libreoffice.LibreOffice -y
  
  # Fix for zoom flatpak
  flatpak override --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom
  
  reboot
else
  echo "Nixbook Install Cancelled!"
fi
