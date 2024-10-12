echo "Installing NixBook..."

cp -R /etc/nixbook/config/config ~/.config
cp -R /etc/nixbook/config/local ~/.local

sudo sed -i '/hardware-configuration\.nix/a\      /etc/nixbook/base.nix' /etc/nixos/configuration.nix
sudo nixos-rebuild switch

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
reboot
