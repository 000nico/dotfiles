## Install

Run these commands from the repository directory:

```bash
mkdir -p "$HOME/.config" "$HOME/.local/bin"
cp -a .config/. "$HOME/.config/"
cp -a .local/bin/. "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/menu" \
    "$HOME/.local/bin/dur-screensaver-start" \
    "$HOME/.local/bin/dur-screensaver-stop" \
    "$HOME/.local/bin/dur-screensaver-player" \
    "$HOME/.config/mango/screenshot" \
    "$HOME/.config/mango/wallpaper" \
    "$HOME/.config/mango/wallpaper_switcher"
systemctl --user daemon-reload
systemctl --user enable --now swayidle-screensaver.service
```

Install the system-wide Fontconfig file separately:

```bash
sudo install -Dm644 etc/fonts/local.conf /etc/fonts/local.conf
fc-cache -f
```

Make sure the required packages are installed before starting Mango:

```bash
sudo pacman -S --needed \
    rofi grim slurp satty wf-recorder wl-clipboard \
    networkmanager bluetui wiremix swayidle brightnessctl \
    pamixer playerctl swaybg kitty waybar mako cava \
    pacman-contrib ttf-jetbrains-mono-nerd
```

Optional packages:

```bash
sudo pacman -S --needed swaylock tty-clock
```

## Notes

- `super+Space` launches `/home/nico/.local/bin/menu`.
- The menu uses `kitty --class menu-float` for terminal TUIs. Add a Mango rule for the `menu-float` app ID after checking the exact rule syntax for the installed Mango version.
- The wallpaper menu reads images from `$HOME/Pictures/wallpapers`. That directory is intentionally not part of this repository.
- The menu stores the selected wallpaper in `$HOME/.config/mango/last-wallpaper`, which is runtime state and is intentionally not included.
