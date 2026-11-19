# Void Linux + Umbriel

Complete configuration of my machine: dotfiles, scripts, packages, fonts,
icons, themes and wallpapers required to reproduce the installation.

## System

| Component | Detail |
|---|---|
| Distribution | Void Linux x86_64, runit, elogind |
| Kernel | `linux` 6.18 |
| Compositor | Umbriel (wlroots), installed in `~/.local` |
| Desktop shell | Noctalia 5.1 (Quickshell) |
| Display manager | Ly |
| Audio | PipeWire + WirePlumber (ALSA and Pulse) |
| Network | NetworkManager |
| Terminal | kitty |
| Shell | fish |
| GTK theme | Colloid Dark Compact |
| Icons | Pixora, Pixelitos, Scribbled |
| Fonts | BigBlueTermPlus Nerd Font, Fira Code, JetBrainsMono NL Nerd Font |
| Reference hardware | HP EliteBook 640 G10, Intel Raptor Lake-P (`sof-hda-dsp`) |

## Contents

- `packages/`: manually installed xbps packages (`explicit.txt`), the full set
  of package names (`installed-names.txt`, used by the installer), the versioned
  tree (`installed.txt`) and flatpaks.
- `system/`: files from `/etc` (Ly, PipeWire, xbps repositories, udev rules,
  locale) and the list of enabled runit services.
- `home/`: dotfiles, scripts, fonts, icons, themes and wallpapers.

## Installation

On a fresh Void Linux install, as a regular user with sudo:

```sh
git clone https://github.com/000nico/dotfiles.git
cd dotfiles
./install.sh
```

The script adds the repositories, installs the packages, copies `/etc` and the
home directory, enables the runit services and rebuilds the font and icon
caches. Reboot afterwards: Ly starts the session and Umbriel brings up the
desktop.

## Notes

- The scripts assume user `nico` and `HOME=/home/nico`. With a different user
  the absolute paths in `~/.local/bin` and `~/.config/fish` must be adjusted.
- The timezone is set from the session (`America/Argentina/Buenos_Aires`)
  because the original system has no `/etc/localtime` configured.
- No keys, tokens or browser profiles are included.
- Applications living in `~/.local/opt` are not included due to size: Zed,
  IntelliJ IDEA, Discord, Spotifast, Zapfast and Antigravity are installed
  separately.
- The Umbriel binary is included in `home/.local/libexec/umbriel`.
- `~/.config/pipewire/disabled-conf.d` keeps the `context.exec` definitions
  that were removed to avoid launching WirePlumber twice.
