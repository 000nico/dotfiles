## Included

- MangoWM configuration and keybindings, including `Super+Space` for the utility menu.
- `~/.local/bin/menu` with Rofi submenus, screenshots, recordings, updates, maintenance, connectivity, Cava, and wallpaper selection.
- The Mango screensaver scripts and their `swayidle` user service.
- Kitty, Waybar, Mako, Rofi, and Cava configuration.
- System-wide Fontconfig defaults for JetBrains Mono Nerd Font.

Wallpapers and the Fastfetch preview image are included. Browser profiles, cookies, dconf databases, caches, and runtime state remain excluded.

## Install

En una instalación nueva de Arch, cloná este repositorio y ejecutá:

```bash
./install.sh
```

## Notes

- `super+Space` launches `~/.local/bin/menu`.
- The menu uses `kitty --class menu-float` for terminal TUIs. Add a Mango rule for the `menu-float` app ID after checking the exact rule syntax for the installed Mango version.
- The wallpaper menu reads the included images from `$HOME/Pictures/wallpapers`.
- The menu stores the selected wallpaper in `$HOME/.config/mango/last-wallpaper`, which is runtime state and is intentionally not included.
