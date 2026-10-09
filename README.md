# dotfiles

Rice para [MangoWM](https://github.com/mangowm/mango) + Wayland, con installer
tanto para Arch Linux como para Fedora.

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

En una instalación nueva de Arch, cloná este repositorio y ejecutá:

```bash
./install.sh
```

El script instala los paquetes nativos de `packages.txt` (incluye `slurp`,
`wireplumber`, `libnotify`, etc.) y los paquetes AUR de `aur-packages.txt`,
compilando `yay` si todavía no está instalado. Después copia todas las
configuraciones, scripts, wallpapers, fuentes, TLP y Ly (config + animación
DurMovie usada por Ly y por el screensaver), habilita los servicios y conserva
backups de los archivos existentes con el sufijo `.before-dotfiles`.

## Install (Fedora)

En una instalación de Fedora (netinstall "Everything" o Workstation), cloná
este repositorio y ejecutá:

```bash
./install-fedora.sh
```

Hace lo mismo que `install.sh` pero con dnf y los nombres de paquete de Fedora:

- Activa **RPM Fusion**, **Terra** (donde vive `mangowm`) y **Flathub**.
- Instala paquetes oficiales mapeados uno a uno desde `packages.txt`.
- Descarga **JetBrainsMono Nerd Font** (no está empaquetada en Fedora).
- Compila o descarga lo que no está empaquetado (`bluetui`, `wl-clip-persist`,
  `lazygit`, `tty-clock`, `durdraw`).
- Instala `Obsidian` e `IntelliJ` por Flatpak.
- Display manager: `ly` si tu release lo tiene; si no, lo compila desde
  fuente y si eso falla usa `greetd` con autologin a Mango.
- Copia las mismas configs, scripts, wallpapers, fuentes, TLP y Ly, y habilita
  TLP, Bluetooth, PipeWire, el screensaver y el display manager.

El instalador de Fedora también crea el socket de usuario de `wob` si el paquete
no lo trae y enlaza `fd` → `fdfind`, porque Fedora empaqueta el programa con
otro nombre.

## Notes

- `super+Space` launches `~/.local/bin/menu`.
- The menu uses `foot --app-id menu-float` for terminal TUIs.
- The wallpaper menu reads the included images from `$HOME/Pictures/wallpapers`.
- The menu stores the selected wallpaper in `$HOME/.config/mango/.current_wallpaper`,
  which is runtime state and is intentionally not included.
- El instalador crea una configuración de LazyVim solamente si
  `~/.config/nvim` todavía no existe. No copia perfiles del navegador, cookies,
  bases dconf ni caches.