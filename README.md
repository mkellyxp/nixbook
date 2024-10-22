![nixbook os logo](https://github.com/user-attachments/assets/8511e040-ebf0-4090-b920-c051b23fcc9c)

**Convert your old laptop (even chromebook) to a user friendly, lightweight, durable, and auto updating operating system build on top of NixOS.**

The goal is to create a "chromebook like" unbreakable computer to give to basic users who know nothing about Linux and won't need to ever worry about updates / upgrades.

The default **nixbook** version:
- * 32 gigs of storage and 4 gigs of ram recommended *
- configured cinnamon desktop and firefox base
- Chrome, Zoom, and Libreoffice installed by default flathub enabled out of the box.
- Automatic weekly updates with 4 weeks of roll backs


The **nixbook lite** version:
- * 16 gigs of storage and 2gigs of ram recommended *
- configured cinnamon desktop and firefox base
- Automatic weekly updates with 2 weeks of roll backs
  

![Screenshot from 2024-10-17 09-05-35](https://github.com/user-attachments/assets/5564c57f-078b-429b-923f-49c2f215a907)


## Step 1:  Install NixOS, and choose the No Desktop option.

![Screenshot from 2024-10-12 10-24-21](https://github.com/user-attachments/assets/865760ec-fcd1-4133-be35-5fb5cf0e6638)


## Step 2:  Enable unfree software

![Screenshot from 2024-10-12 10-24-31](https://github.com/user-attachments/assets/77b02843-4c3e-409c-82dc-7579578b2582)


## Step 3:  Format your drive however you like (Enable swap if you have more than 16gig of hard drive space)

![Screenshot from 2024-10-12 10-24-44](https://github.com/user-attachments/assets/968111d9-c018-4be5-8aaa-ee5c647b2617)


## Step 4:  Reboot, login, and connect to wifi, then hit ESC

```
nmtui
```


## Step 5:  Go to /etc and have git ready
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

* or for nixbook lite *
```
cd nixbook
./install_lite.sh
```


## Step 8:  The install script will ask for your admin password one more time, to install flathub, and will reboot!

![Screenshot from 2024-10-12 10-36-59](https://github.com/user-attachments/assets/9c5cbec7-2d84-4047-a364-addd67b0d074)


## Step 9:  Enjoy NixBook!  It's very light on RAM and storage.

It comes with Firefox, Libreoffice, Chrome and Zoom.  And the software center is hooked up to flathub so you can install any flatpaks you want.

---

- NixOS updates are automatic once a week, and are set to apply at reboot. **
- Flatpaks are updated daily along with self updating this git config
- The Nix channel will be updated from this git config once tested, and will auto apply to your machine within a week
- Simply reboot for these changes to apply
- One month of generations will be saved, so if there is a problem with an update, the previous version is still bootable


![Screenshot from 2024-10-12 10-40-07](https://github.com/user-attachments/assets/3540074a-e11e-4a88-a812-4ef3d4c83f0b)

![Screenshot from 2024-10-12 10-40-36](https://github.com/user-attachments/assets/6f62f3da-4a4c-464a-b75b-2046ff4d9162)


---

If you ever want to completely "reset" your machine, simply run "/etc/nixbook/powerwash.sh" and it will delete all local files and make this a new machine.

This is a passion project of mine, that I'm using for friends, family, and my local community at large.  If you have any feedback or suggestions, please feel free to open an issue, pull request or just message me.
