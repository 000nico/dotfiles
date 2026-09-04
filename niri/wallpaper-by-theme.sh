#!/usr/bin/env bash

set -euo pipefail

theme_file="$HOME/.cache/current_system_theme"
case "$(cat "$theme_file" 2>/dev/null || printf 'gruvbox')" in
    pastel-blue)
        wallpaper="$HOME/dotfiles/assets/wallpapers/city.png"
        ;;
    *)
        wallpaper="$HOME/dotfiles/assets/catto.jpg"
        ;;
esac

[ -f "$wallpaper" ] || exit 1
exec swaybg -i "$wallpaper" -m fill
