echo "This will delete ALL local files and reset this Nixbook!";
read -p "Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  # Get latest nixbook code
  sudo git -C /etc/nixbook reset --hard
  sudo git -C /etc/nixbook clean -fd
  sudo git -C /etc/nixbook pull --rebase
  

  # Erase data and set up home directory again
  rm -rf ~/
  mkdir ~/Desktop
  mkdir ~/Documents
  mkdir ~/Downloads
  mkdir ~/Pictures
  mkdir ~/.local
  mkdir ~/.local/share
  cp -R /etc/nixbook/config/config ~/.config
  cp /etc/nixbook/config/desktop/* ~/Desktop/
  cp -R /etc/nixbook/config/applications ~/.local/share/applications

  sudo rm -r /var/lib/flatpak

  # Clear space and rebuild
  sudo nix-collect-garbage -d
  sudo nixos-rebuild switch --upgrade
  sudo nixos-rebuild list-generations

  # Add flathub and some apps
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub com.google.Chrome -y
  flatpak install flathub us.zoom.Zoom -y
  flatpak install flathub org.libreoffice.LibreOffice -y

  # Flatpak Override for Blank Screens in Zoom
  flatpak override --user --env=ZYPAK_ZYGOTE_STRATEGY_SPAWN=0 us.zoom.Zoom
  
  reboot
else
  echo "Powerwashing Cancelled!"
fi
