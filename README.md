<div align="center">

# nico dotfiles

**NixOS · Niri · Personal Desktop**

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
| Shell / Bar       | Waybar                  |
| Launcher          | Wofi                    |
| Notifications     | Mako                    |
| Wallpaper         | swww / theme script     |
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
├── quickshell/shell.qml         # Optional shell UI
├── kitty/kitty.conf             # Terminal configuration
├── waybar/                      # Bar configuration and scripts
├── wofi/                        # App launcher configuration
├── mako/config                  # Notification daemon configuration
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
├── assets/                      # Wallpapers and other assets
└── install.sh                   # Recreate the ~/.config symlinks
```

---

## Installation

The NixOS configuration is the source of truth for system packages,
Quickshell, and the Minecraft-inspired default font:

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nixos
```

Tracked desktop configuration is linked from `~/.config`; private application
data remains outside the repository. Run `./install.sh` after cloning to recreate
the links for the desktop configuration and home dotfiles.

## 🎨 Themes

The setup includes purple, pastel blue, and cute pink theme palettes. The
Waybar theme switcher updates the supported desktop components together.

---

## Key Bindings (Niri)

| Shortcut        | Action               |
|-----------------|----------------------|
| `Mod+Return`    | Open terminal        |
| `Mod+R`        | App launcher (Wofi)  |
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
<sub>Built for NixOS + Niri.</sub>
</div>
