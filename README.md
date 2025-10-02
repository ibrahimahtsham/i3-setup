Minimal Ubuntu Server + i3 + kitty (startx)

Goal
- Ultra‑minimal, clean setup using defaults (dark look with minimal tweaks)
- Only install exactly what’s needed; keep configs and scripts short
- TTY login → startx → i3 with kitty; repeatable setup later via one‑shot
- Apps via Flatpak (Firefox, Discord) and VS Code when ready; simple status bar

What you get (short)
- TTY login, then startx into i3 (no display manager)
- Kitty as default terminal, clean/dark defaults (from this repo’s scripts later)
- i3bar via custom scripts/statusbar.sh (no i3status): BRI/V/BAT/Wi/CPU/GPU/RAM/T; scroll on BRI adjusts brightness

Setup (now)
1) Install core packages
```bash
sudo apt update
sudo apt install -y --no-install-recommends xorg xinit i3-wm dmenu kitty dbus-x11 policykit-1
# Optional for brightness control and audio integration
sudo apt install -y brightnessctl pulseaudio-utils || true
sudo apt install -y pipewire wireplumber pipewire-audio-client-libraries || true
```

2) Minimal ~/.xinitrc
```sh
#!/bin/sh
exec i3
```

3) Link configs and start i3
```bash
./sync.sh
startx
```

Specs (Chromebook): 4GB RAM • 32GB eMMC • Intel Celeron N4000