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

## 📂 Repo Structure
dotfiles-i3/
│── setup.sh           -> Main setup script (symlinks + installs deps)
│── configs/
│   ├── i3/config      -> i3 WM config
│   ├── i3blocks.conf  -> i3blocks status bar config
│   └── scripts/       -> helper scripts (audio fix, shortcut guide)
│
└── README.md          -> this file

## ⚡ Quick Start
Clone repo:
    git clone https://github.com/YOURUSERNAME/dotfiles-i3.git ~/dotfiles-i3
    cd ~/dotfiles-i3

Run setup:
    chmod +x setup.sh
    ./setup.sh

Reboot and you’re ready 🎉

## 📝 Notes
- Everything is managed via GitHub → edit configs only inside this repo
- Reinstalling on a new machine? Just clone and run setup.sh
- Scripts in configs/scripts/ will handle Chromebook-specific quirks (like audio)
