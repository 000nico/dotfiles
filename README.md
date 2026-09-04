<div align="center">

# nico dotfiles

**NixOS · Niri · Amber Dark Theme**

![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?style=for-the-badge&logo=nixos&logoColor=white)
![Niri](https://img.shields.io/badge/Niri-WM-ffc060?style=for-the-badge)
![Wayland](https://img.shields.io/badge/Wayland-orange?style=for-the-badge)

</div>

---

## Stack

| Role              | Tool                    |
|-------------------|-------------------------|
| OS                | NixOS (unstable)        |
| Window Manager    | Niri                    |
| Display Manager   | SDDM (Wayland)          |
| Terminal          | Kitty                   |
| Shell             | Zsh + Powerlevel10k     |
| Editor            | Neovim (LazyVim)        |
| Shell / Bar       | Quickshell              |
| Launcher          | Fuzzel                  |
| Notifications     | Quickshell              |
| Wallpaper         | swaybg                  |
| File Manager      | Yazi + Nautilus         |
| Browser           | Librewolf               |
| Chat              | Vesktop (Discord)       |
| IDE               | VSCodium / IntelliJ IDEA|
| Audio             | PipeWire + WirePlumber  |
| Bluetooth         | BlueZ + Blueman         |
| Fetch             | Fastfetch               |
| Monitor           | Btop                    |
| Audio Viz         | Cava                    |

---

## 🗂 Structure

```
dotfiles/
├── flake.nix                    # Nix flake entry point
├── nixos/
│   ├── configuration.nix        # Main NixOS system config
│   └── hardware-configuration.nix
│
├── niri/config.kdl              # Niri WM keybinds, layout, rules
├── quickshell/shell.qml         # Transparent shell, menus & notifications
├── kitty/kitty.conf             # Terminal config (amber theme)
├── waybar/                      # Legacy bar config and scripts
├── wofi/                        # App launcher styles
├── mako/config                  # Legacy notification daemon config
├── fastfetch/config.jsonc       # System info display
├── btop/btop.conf               # System monitor
├── cava/config                  # Audio visualizer
├── yazi/yazi.toml               # TUI file manager config
├── nvim/                        # Neovim (LazyVim) config
│
├── .zshrc                       # Zsh config (NixOS paths, plugins)
├── .p10k.zsh                    # Powerlevel10k prompt config
├── .gitconfig                   # Git global settings
│
└── assets/                      # Wallpapers & Assets (catto.jpg)
```

---

## Installation

The NixOS configuration is the source of truth for system packages,
Quickshell, and the Minecraft-inspired default font:

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

Tracked desktop configuration is linked from `~/.config`; private application
data remains outside the repository. Quickshell is started by Niri from
`quickshell/shell.qml` and provides the transparent panel, theme and wallpaper
controls, workspace switcher, power menu, settings view, and notification
popups.

## 🎨 Theme: Amber Dark

Orange/amber accent colors on a deep dark background (`#0a0704`).

| Color    | Hex       |
|----------|-----------|
| Accent 1 | `#ffc060` |
| Accent 2 | `#e07020` |
| Border   | `#ffb040` |
| BG       | `#0a0704` |
| Text     | `#f5dfc8` |

---

## Key Bindings (Niri)

| Shortcut        | Action               |
|-----------------|----------------------|
| `Mod+Return`    | Open terminal        |
| `Mod+R / D`     | App launcher (Wofi)  |
| `Mod+W`         | Librewolf            |
| `Mod+E`         | Yazi file manager    |
| `Mod+C`         | Close window         |
| `Mod+F`         | Maximize column      |
| `Mod+V`         | Toggle floating      |
| `Mod+X`         | Power menu           |
| `Mod+L`         | Lock session         |
| `Mod+Shift+E`   | Quit session         |
| `Print`         | Screenshot (region)  |
| `Mod+Print`     | Screenshot (screen)  |
| `Mod+1..9`      | Switch workspace     |
| `Mod+O`         | Overview             |

---

<div align="center">
<sub>Built for NixOS + Niri — forked from CachyOS/Hyprland origins 🐉</sub>
</div>
