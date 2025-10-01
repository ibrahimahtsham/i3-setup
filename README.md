# Chromebook i3 Setup 🚀

## 🖥 System Info
- Device: Chromebook
- CPU: Intel Celeron N4000 (dual-core @ 1.1GHz)
- GPU: Intel UHD 600
- RAM: 4GB
- Storage: 32GB eMMC

## 📦 What This Setup Installs
- Ubuntu Minimal (lightweight base, stable & auto updates)
- i3 Window Manager (tiling, fast, minimal)
- Rofi (application launcher, replaces dmenu)
- i3blocks (lightweight status bar for system info)
- Flatpak (to install apps easily)
- Apps:
  - Firefox
  - VS Code (official Microsoft build)
  - Discord

Extras:
- Scripts for Chromebook audio fixes & autostart helpers
- Shortcut guide that runs on login

## 📥 Get the ISO
Download Ubuntu Server (minimal base for i3 setup):  
👉 https://ubuntu.com/download/server

Flash the ISO to USB (with Balena Etcher or `dd`), then boot your Chromebook (requires Developer Mode + MrChromebox UEFI firmware).

## 📂 Repo Structure
```text
i3-setup/
│── setup.sh           -> Main setup script (symlinks + installs deps)
│── configs/
│   ├── i3/config      -> i3 WM config
│   ├── i3blocks.conf  -> i3blocks status bar config
│   └── scripts/       -> helper scripts (audio fix, shortcut guide)
│
└── README.md          -> this file
```

## ⚡ Quick Start


Clone repo:
```bash
git clone https://github.com/ibrahiahtsham/i3-setup.git ~/i3-setup
cd ~/i3-setup
```


Run setup:
```bash
chmod +x setup.sh
./setup.sh
```

Reboot and you’re ready 🎉

## 🔹 Step 4: Install i3
After installing Ubuntu Server and logging in:


```bash
sudo apt update && sudo apt upgrade -y
sudo apt install i3 rofi i3blocks flatpak gnome-software -y
```

## 📝 Notes
- Everything is managed via GitHub → edit configs only inside this repo
- Reinstalling on a new machine? Just clone and run setup.sh
- Scripts in configs/scripts/ will handle Chromebook-specific quirks (like audio)
