read -p "This will delete ALL local files and reset this Nixbook!  Do you want to continue? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
echo "Powerwashing NixBook..."
  rm -rf ~/*
  cp -R /etc/nixbook/config/config ~/.config
  cp -R /etc/nixbook/config/local ~/.local
  reboot
else
  echo "Powerwashing Cancelled!"
fi
