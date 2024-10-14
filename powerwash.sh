read -p "This will delete ALL local files and reset this Nixbook!  Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  git -C /etc/nixbook pull
  rm -rf ~/
  cp -R /etc/nixbook/config/config ~/.config
  reboot
else
  echo "Powerwashing Cancelled!"
fi
