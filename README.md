Minimal Ubuntu Server + i3 + kitty (startx)

Goal
- Ultra‑minimal, clean setup using defaults (dark look with minimal tweaks)
- Only install exactly what’s needed; keep configs and scripts short
- TTY login → startx → i3 with kitty; repeatable setup later via one‑shot
- Apps via Flatpak (Firefox, Discord) and VS Code when ready; simple status bar

What you get (short)
- TTY login, then startx into i3 (no display manager)
- Kitty as default terminal, clean/dark defaults (from this repo’s scripts later)
- i3bar via custom scripts/statusbar.sh (no i3status): BRI/V/BAT/Wi/CPU/GPU/RAM/T/time; scroll on BRI/V adjusts brightness/volume

Setup (seamless)
1) Install core + audio/brightness packages
```bash
sudo apt update
sudo apt install -y --no-install-recommends xorg xinit i3-wm dmenu kitty dbus-x11 policykit-1
sudo apt install -y brightnessctl pipewire wireplumber pipewire-audio-client-libraries pulseaudio-utils alsa-utils alsa-ucm-conf
```

2) Add user to video/audio groups (brightness/devices)
```bash
sudo usermod -aG video,audio "$USER"
# Log out and back in for group membership to take effect
```

3) Minimal ~/.xinitrc
```sh
#!/bin/sh
exec i3
```

4) Link configs and start i3
```bash
./sync.sh
startx
```

Notes
- Status bar blocks: BRI (brightness), V (volume), BAT, Wi, CPU, GPU, RAM, T (temp), time.
- Mouse scroll over BRI/V adjusts brightness/volume in 5% steps.
  

Troubleshooting audio
- If wpctl status shows “Dummy Output” only:
	```bash
	sudo apt install -y alsa-ucm-conf alsa-utils
	systemctl --user restart pipewire wireplumber
	```
- Pick the right default sink (speaker/headphones/HDMI):
	```bash
	wpctl status   # note the sink ID, e.g., 59 for Speaker
	wpctl set-default 59
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 50%
	./scripts/test_audio.sh
	```

Troubleshooting brightness
- brightnessctl should work without root; if it doesn’t:
	- Ensure you’re in the video group (id -nG | grep -qw video) and re-login after adding.
	- Some devices expose multiple backlights; the script auto-picks the first. Open an issue if you need a specific one targeted.

Specs (Chromebook): 4GB RAM • 32GB eMMC • Intel Celeron N4000