# dotfiles

Rice for [MangoWM](https://github.com/mangowm/mango) + with installer for arch & fedora

## Included

- MangoWM configuration and keybindings, including `Super+Space` for the utility menu.
- `~/.local/bin/menu` with Rofi submenus, screenshots, recordings, updates, maintenance, connectivity, Cava, and wallpaper selection.
- The Mango screensaver scripts and their `swayidle` user service.
- Kitty, Foot, Waybar, Mako, Rofi, and Cava configuration.
- Matugen templates that re-theme Waybar, Mako, Kitty, Foot, Rofi and Mango.
- Fontconfig profiles (`equilibrado`, `macos-suave`, `nitido`) toggled with `~/.config/fontconfig/select-profile.sh`.
- System-wide Fontconfig defaults for JetBrainsMono Nerd Font.

Wallpapers and the Fastfetch preview image are included. Browser profiles,
cookies, dconf databases, caches, and runtime state remain excluded.

## Install (Arch Linux)

In a fresh arch:

```bash
./install.sh
```

## Install (Fedora)

In a fresh Fedora Everything (with minimal options):

```bash
./install-fedora.sh
```

## Notes

- `super+Space` launches `~/.local/bin/menu`.
- The menu uses `foot --app-id menu-float` for terminal TUIs.
- The wallpaper menu reads the included images from `$HOME/Pictures/wallpapers`.
- The menu stores the selected wallpaper in `$HOME/.config/mango/.current_wallpaper`,
  which is runtime state and is intentionally not included.
- El instalador crea una configuración de LazyVim solamente si
  `~/.config/nvim` todavía no existe. No copia perfiles del navegador, cookies,
  bases dconf ni caches.
