![nixbook os logo](https://github.com/user-attachments/assets/8511e040-ebf0-4090-b920-c051b23fcc9c)

**Convert your old computer (even chromebook) to a user friendly, lightweight, durable, and auto updating operating system build on top of NixOS.**

The goal is to create a "chromebook like" unbreakable computer to give to basic users who know nothing about Linux and won't need to ever worry about updates / upgrades.

---
**NEW INSTALLER AVAILABLE**
With the help of amazing people in the community, Nixbook now has an official installer in testing.  Download this ISO, flash it to a USB and you can skip ALL of the steps below!  Please let me know if you have any issues with the installer.

[Click here to download the ISO](https://s3.membervaultcdn.com/nixbook/nixbook-installer-25.05.20250726.iso)



---
Full video walk through of converting from Windows to Nixbook is now live here:

<https://youtu.be/izvVjfqd5j8?si=ZJAdBZRsQO38YIy5>
---

The default **nixbook** version:
- ***32 gigs of storage and 4 gigs of ram recommended***
- configured cinnamon desktop and firefox base
- Chrome, Zoom, and Libreoffice installed by default flathub enabled out of the box.
- Automatic weekly OS updates with 4 weeks of roll backs
- Daily flatpak updates


The **nixbook lite** version:
- ***16 gigs of storage and 2 gigs of ram recommended***
- configured cinnamon desktop and firefox base
- Automatic weekly updates with 2 weeks of roll backs
  

![Screenshot from 2024-10-22 10-31-24](https://github.com/user-attachments/assets/53fc76ad-5861-46d8-895a-b4be1e1b2816)


## Step 1:  Install NixOS, and choose the No Desktop option.

![Screenshot from 2024-10-12 10-24-21](https://github.com/user-attachments/assets/865760ec-fcd1-4133-be35-5fb5cf0e6638)


## Step 2:  Enable unfree software

![Screenshot from 2024-10-12 10-24-31](https://github.com/user-attachments/assets/77b02843-4c3e-409c-82dc-7579578b2582)


## Step 3:  Format your drive however you like (erase disk, swap, no hibernate)

![Screenshot from 2024-10-12 10-24-44](https://github.com/user-attachments/assets/968111d9-c018-4be5-8aaa-ee5c647b2617)


## Step 4:  Reboot, login, and connect to wifi, then hit ESC

```
nmtui
```


## Step 5:  Go to /etc and nix-shell git
```
cd /etc/
nix-shell -p git
```


## Step 6:  Clone the nixbook repo  (make sure you run as sudo and you're in /etc!)
```
sudo git clone https://github.com/mkellyxp/nixbook
```

## Step 7:  Run the install script (run this with NO sudo)
```
cd nixbook
./install.sh
```

*or for nixbook lite*
```
cd nixbook
./install_lite.sh
```


## Step 8:  Enjoy nixbook!

You can always manually run updates by running **Update and Reboot** in the menu.

If you want to completely reset this nixbook, wipe off your personal data to give it to someone else, or start fresh, run **Powerwash** from the menu.

---

Notes:
- The Nix channel will be updated from this git config once tested, and will auto apply to your machine within a week
- Simply reboot for OS updates to apply.
- Don't modify the .nix files in this repo, as they'll get overwritten on update.  If you want to customize, put your nix changes directly into /etc/nixos/configuration.nix


![Screenshot from 2024-10-12 10-40-07](https://github.com/user-attachments/assets/3540074a-e11e-4a88-a812-4ef3d4c83f0b)

![Screenshot from 2024-10-12 10-40-36](https://github.com/user-attachments/assets/6f62f3da-4a4c-464a-b75b-2046ff4d9162)


---

This is a passion project of mine, that I'm using for friends, family, and my local community at large.  If you have any feedback or suggestions, please feel free to open an issue, pull request or just message me.

---

If at any point you're having issues with your nixbook not updating, check the auto-update-config service by running 

```
sudo systemctl status auto-update-config
```

If it shows any errors, go directly to /etc/nixbook and run

```
sudo git pull --rebase
```

Then you can start the autoupdate service again by running

```
sudo systemctl status auto-update-config
```
