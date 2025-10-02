# i3 Chromebook setup

Minimal i3 setup for Chromebook (Intel UHD 600). Includes i3, rofi (app launcher), i3blocks, and helper scripts.

- Setup script: [setup.sh](setup.sh)
- i3 config: [configs/i3/config](configs/i3/config)
- i3blocks config: [configs/i3blocks.conf](configs/i3blocks.conf)
- Scripts: [configs/scripts](configs/scripts)

## What you get
- i3 with sensible keybinds
- i3blocks with: brightness, volume, battery, CPU/RAM/GPU usage, temp, network, local time
- Chromebook helpers: audio fix, brightness via brightnessctl

## Replicate this setup
- Install base packages (Ubuntu/Debian example; use equivalents for Arch/Fedora):
  - sudo apt update && sudo apt install -y i3 rofi i3blocks flatpak gnome-software
- Clone and link configs:
  - git clone https://github.com/ibrahiahtsham/i3-setup.git ~/i3-setup
  - cd ~/i3-setup && chmod +x setup.sh && ./setup.sh
- Optional: allow brightness control without root
  - sudo usermod -aG video "$USER" && newgrp video
- Start or restart i3
  - Mod+Shift+r to reload i3 after running setup

Note:
- setup.sh will install brightnessctl if missing (apt/pacman/dnf).
- For audio issues, try: [configs/scripts/audio-fix.sh](configs/scripts/audio-fix.sh)
 - Timezone uses your system's local time. To auto-detect on Debian/Ubuntu: `sudo timedatectl set-ntp true && sudo timedatectl set-timezone $(curl -fsSL https://ipapi.co/timezone || echo Etc/UTC)`

## i3 quick keys
- Mod+Enter: terminal
- Mod+d: rofi app launcher (drun). You can switch to dmenu if you prefer.
 - Mod+d: rofi app launcher (drun). You can switch to dmenu if you prefer.
 - Mod+p: rofi launcher with Flatpak-aware env (wrapper script)
- Mod+h/v: split horiz/vert
- Mod+f: fullscreen
- Mod+Shift+q: close
- Mod+1..9: workspaces
- Mod+Shift+1..9: move to workspace
- Mod+Shift+c/r: reload/restart i3

## i3blocks usage
- Brightness: scroll to change (needs brightnessctl) → [configs/scripts/brightness.sh](configs/scripts/brightness.sh)
- Volume: scroll to change, click to mute → [configs/scripts/volume.sh](configs/scripts/volume.sh)
- Other modules: [battery](configs/scripts/battery.sh), [cpu](configs/scripts/cpu.sh), [ram](configs/scripts/ram.sh), [gpu](configs/scripts/gpu.sh), [temp](configs/scripts/temp.sh), [network](configs/scripts/network.sh)