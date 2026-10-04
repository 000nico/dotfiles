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

El script instala los paquetes nativos de `packages.txt` y los paquetes AUR de
`aur-packages.txt`, incluyendo `yay` si todavía no está instalado. Después
copia todas las configuraciones, scripts, wallpapers, fuentes y archivos de
TLP, habilita el servicio de screensaver y conserva backups de los archivos
existentes con el sufijo `.before-dotfiles`.

El instalador también crea una configuración de LazyVim solamente si
`~/.config/nvim` todavía no existe. No copia perfiles del navegador, cookies,
bases dconf ni caches.

## Notes

- `super+Space` launches `~/.local/bin/menu`.
- The menu uses `kitty --class menu-float` for terminal TUIs. Add a Mango rule for the `menu-float` app ID after checking the exact rule syntax for the installed Mango version.
- The wallpaper menu reads the included images from `$HOME/Pictures/wallpapers`.
- The menu stores the selected wallpaper in `$HOME/.config/mango/last-wallpaper`, which is runtime state and is intentionally not included.
