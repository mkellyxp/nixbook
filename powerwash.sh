read -p "This will delete ALL local files and reset this Nixbook!  Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  sudo git -C /etc/nixbook pull
  sudo nixos-rebuild boot --upgrade
  rm -rf ~/
  cp -R /etc/nixbook/config/config ~/.config
  reboot
else
  echo "Powerwashing Cancelled!"
fi
