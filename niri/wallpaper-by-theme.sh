#!/usr/bin/env bash

set -euo pipefail

theme_file="$HOME/.cache/current_system_theme"
wallpaper_file="$HOME/.cache/current_wallpaper"
saved_wallpaper="$(cat "$wallpaper_file" 2>/dev/null || true)"
if [[ -f "$saved_wallpaper" ]]; then
    exec "$HOME/.config/scripts/wallpicker.sh" set "$saved_wallpaper"
fi

wallpaper_dir="$HOME/Pictures/wallpapers"
first_wallpaper="$(
    find "$wallpaper_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print -quit 2>/dev/null || true
)"

[[ -n "$first_wallpaper" ]] || exit 0
exec "$HOME/.config/scripts/wallpicker.sh" set "$first_wallpaper"
