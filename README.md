Minimal Ubuntu Server + i3 + ly + kitty

What you get
- Super minimal i3 on Xorg with ly as the display manager
- Kitty as the default terminal (no xterm)
- Flatpak + Flathub with Firefox and Discord
- Clean defaults + dark theme (applied by the repo’s setup script)
- i3bar with: battery, Wi‑Fi, brightness, volume, time/date, CPU usage/temp, GPU usage, RAM usage, and a Bluetooth tray applet. Scroll on volume/brightness to adjust.

1) Install Ubuntu Server
- Get ISO: https://ubuntu.com/download/server
- During install, keep it minimal. After first boot, log in on TTY.

2) One‑shot setup (copy/paste)
Run this as your user with sudo rights. It installs i3, kitty, ly, Flatpak, core tooling, and enables needed services.

```bash
sudo apt update && \
sudo apt install -y \
	xorg i3-wm i3lock dmenu \
	i3status-rust kitty \
	ly \
	network-manager network-manager-gnome \
	blueman bluez bluez-tools \
	brightnessctl lm-sensors intel-gpu-tools \
	pipewire pipewire-pulse wireplumber \
	flatpak xdg-desktop-portal xdg-desktop-portal-gtk \
	git curl && \
sudo systemctl enable ly --now && \
sudo systemctl enable bluetooth --now && \
sudo usermod -aG video "$USER" && \
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50 && \
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty && \
sudo apt purge -y xterm || true && \
sudo snap remove firefox || true && \
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
flatpak install -y flathub org.mozilla.firefox com.discordapp.Discord
```

Notes
- If your apt can’t find “ly”, install it from upstream: https://github.com/fairyglade/ly
- i3bar’s tray will host nm-applet and blueman-applet. We use i3status‑rust for the metrics blocks.
- GPU usage on Intel is read via intel-gpu-tools; this repo adds a tiny helper script the bar will call.

3) Apply my configs
```bash
git clone https://github.com/ibrahimahtsham/i3-setup.git
cd i3-setup
./scripts/main.sh
```
The main script will:
- Symlink minimal configs for i3, kitty, and status bar
- Set dark theme defaults
- Bind scroll actions for volume/brightness
- Wire Bluetooth manager (blueman-manager) from the bar

Bar modules in this setup
- Battery
- Wi‑Fi SSID/quality
- Volume (scroll to change)
- Brightness (scroll to change)
- Time / Date
- CPU usage + temp
- GPU usage (Intel)
- RAM usage
- Tray: NetworkManager + Bluetooth

Device notes (Chromebook)
- 4 GB RAM
- 32 GB eMMC storage
- Intel Celeron N4000 (UHD Graphics)

That’s it. After running the script, reboot or log out and you should land in ly → i3 with kitty and the minimal dark setup.