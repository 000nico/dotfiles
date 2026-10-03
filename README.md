# Nico's MangoWM dotfiles

This repository contains the current MangoWM desktop configuration and the utility scripts used by the session.

## Included

- MangoWM configuration and keybindings, including `Super+Space` for the utility menu.
- `~/.local/bin/menu` with Rofi submenus, screenshots, recordings, updates, maintenance, connectivity, Cava, and wallpaper selection.
- The Mango screensaver scripts and their `swayidle` user service.
- Kitty, Waybar, Mako, Rofi, and Cava configuration.
- System-wide Fontconfig defaults for JetBrains Mono Nerd Font.

Wallpapers and the Fastfetch preview image are included. Browser profiles, cookies, dconf databases, caches, and runtime state remain excluded.

## Install

Run these commands from the repository directory:

```bash
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures/wallpapers"
cp -a .config/. "$HOME/.config/"
cp -a .local/bin/. "$HOME/.local/bin/"
cp -a Pictures/wallpapers/. "$HOME/Pictures/wallpapers/"
cp -a Pictures/fetchimage.png "$HOME/Pictures/fetchimage.png"
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
- The wallpaper menu reads the included images from `$HOME/Pictures/wallpapers`.
- The menu stores the selected wallpaper in `$HOME/.config/mango/last-wallpaper`, which is runtime state and is intentionally not included.
