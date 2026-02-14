![nixbook os logo](https://github.com/user-attachments/assets/8511e040-ebf0-4090-b920-c051b23fcc9c)

**Convert your old computer (even chromebook) to a user friendly, lightweight, durable, and auto updating operating system build on top of NixOS.**

The goal is to create a "chromebook like" unbreakable computer to give to basic users who know nothing about Linux and won't need to ever worry about updates / upgrades.

Advanced users: see caveats below.

---

The default **nixbook** version:
- ***32 GB of storage and 4 GB of ram recommended***
- configured cinnamon desktop (like Linux Mint) and firefox base
- Chrome, Zoom, and Libreoffice installed by default flathub enabled out of the box.
- Automatic weekly OS updates with 4 weeks of roll backs
- Daily flatpak updates


The **nixbook lite** version:
- ***32 GB of storage and 2 GB of ram recommended***
- configured cinnamon desktop (like Linux Mint) and firefox base
- Automatic weekly updates with 2 weeks of roll backs
  

![Screenshot from 2024-10-22 10-31-24](https://github.com/user-attachments/assets/53fc76ad-5861-46d8-895a-b4be1e1b2816)

---

## Download the Installer
[Click here to download the ISO](https://s3.membervaultcdn.com/nixbook/nixbook-installer-25.11.iso)

---
You can always manually run updates by running **Update and Reboot** in the menu.

If you want to completely reset this nixbook, wipe off your personal data to give it to someone else, or start fresh, run **Powerwash** from the menu.

---

Notes:
- The Nix channel will be updated from this git config once tested, and will auto apply to your machine within a week
- Simply reboot for OS updates to apply.

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
sudo systemctl restart auto-update-config
```

---

Advanced Users:

- Encryption is not supported #63
- Dual boot is not supported and probably will not work out of the box
- Nix has high storage requirements. It is not super feasible to use below 32 GB of storage. #59
- NixOS manages packages differently from other distros. See below, and [this page](https://nixos.org/manual/nixos/stable/#sec-package-management), and [this page](https://jorel.dev/NixOS4Noobs/nixsandboxes.html).

Remember,

> The goal is to create a "chromebook like" unbreakable computer to give to basic users who know nothing about Linux and won't need to ever worry about updates / upgrades.

This OS may be missing some packages you expect out of the box on many Linux distros. You can add them yourself. If you want to customize, put your nix changes directly into `/etc/nixos/configuration.nix`. For example, `sudo nano /etc/configuration.nix`. Don't modify the .nix files in this repo, as they'll get overwritten on update.  You can create a temporary shell with the needed package (for example, ffmpeg) with `nix-shell -p ffmpeg`.
