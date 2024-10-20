![nixbook os logo](https://github.com/user-attachments/assets/8511e040-ebf0-4090-b920-c051b23fcc9c)

**Convert your old laptop (even chromebook) to a user friendly, lightweight, durable, and auto updating operating system build on top of NixOS.**

The goal is to create a "chromebook like" unbreakable computer to give to basic users who know nothing about Linux and won't need to ever worry about updates / upgrades.

![Screenshot from 2024-10-17 09-05-35](https://github.com/user-attachments/assets/5564c57f-078b-429b-923f-49c2f215a907)


## Step 1:  Install NixOS, and choose the No Desktop option.

![Screenshot from 2024-10-12 10-24-21](https://github.com/user-attachments/assets/865760ec-fcd1-4133-be35-5fb5cf0e6638)


## Step 2:  Enable unfree software

![Screenshot from 2024-10-12 10-24-31](https://github.com/user-attachments/assets/77b02843-4c3e-409c-82dc-7579578b2582)


## Step 3:  Format your drive however you like (Enable swap if you have more than 16gig of hard drive space)

![Screenshot from 2024-10-12 10-24-44](https://github.com/user-attachments/assets/968111d9-c018-4be5-8aaa-ee5c647b2617)


## Step 4:  Reboot, login, and run "nmtui" to connect to wifi, then hit ESC

```
nmtui
```

![Screenshot from 2024-10-12 10-30-08](https://github.com/user-attachments/assets/5ab1db5e-ee71-4df5-89dd-18ebdc49d5e4)


## Step 5:  Run "cd /etc/" and then "nix-shell -p git" to download git
```
cd /etc/
nix-shell -p git
```

![Screenshot from 2024-10-12 10-30-44](https://github.com/user-attachments/assets/4dbfed1b-fe37-434e-980a-d8242148badf)


## Step 6:  Run "sudo git clone https://github.com/mkellyxp/nixbook"  (make sure you run as sudo and you're in /etc!)
```
sudo git clone https://github.com/mkellyxp/nixbook
```

## Step 7:  Run "cd nixbook" and run "./install.sh" (run this with NO sudo)

![Screenshot from 2024-10-12 10-32-06](https://github.com/user-attachments/assets/e5acdb79-3b62-4662-b2e8-da9246a67bea)


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
