#!/usr/bin/env bash

set -euo pipefail

readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers"
readonly FALLBACK_WALLPAPER_DIR="$HOME/Pictures"
readonly CACHE_DIR="$HOME/.cache/wallpicker"
readonly CURRENT_FILE="$HOME/.cache/current_wallpaper"
readonly STYLE_FILE="$HOME/.config/wofi/wallpaper.css"

mkdir -p "$CACHE_DIR" "$(dirname "$CURRENT_FILE")"

if ! command -v magick >/dev/null 2>&1; then
    printf '%s\n' "ImageMagick is required to create wallpaper thumbnails." >&2
    exit 1
fi

wallpapers=()
wallpaper_source="$WALLPAPER_DIR"
if [[ ! -d "$wallpaper_source" ]] || ! find "$wallpaper_source" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    -print -quit 2>/dev/null | grep -q .; then
    wallpaper_source="$FALLBACK_WALLPAPER_DIR"
fi

if [[ -d "$wallpaper_source" ]]; then
    while IFS= read -r -d '' wallpaper; do
        wallpapers+=("$wallpaper")
    done < <(
        find "$wallpaper_source" -maxdepth 1 -type f \
            \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
            -print0 | sort -z
    )
fi

if ((${#wallpapers[@]} == 0)); then
    printf '%s\n' "No wallpapers found in $WALLPAPER_DIR." >&2
    command -v notify-send >/dev/null 2>&1 &&
        notify-send "Wallpaper picker" "No wallpapers found in ~/Pictures/wallpapers"
    exit 1
fi

thumbnail_for() {
    local wallpaper="$1"
    local key thumbnail metadata signature

    key="$(printf '%s' "$wallpaper" | sha256sum | cut -d' ' -f1)"
    thumbnail="$CACHE_DIR/$key.png"
    metadata="$CACHE_DIR/$key.meta"
    signature="$(stat -c '%Y:%s' "$wallpaper")"

    if [[ ! -f "$thumbnail" || ! -f "$metadata" || "$(cat "$metadata")" != "$signature" ]]; then
        magick "$wallpaper[0]" \
            -thumbnail '320x180^' \
            -gravity center \
            -extent 320x180 \
            "$thumbnail"
        printf '%s\n' "$signature" > "$metadata"
    fi

    printf '%s\n' "$thumbnail"
}

apply_wallpaper() {
    local wallpaper="$1"

    [[ -f "$wallpaper" ]] || {
        printf 'Wallpaper not found: %s\n' "$wallpaper" >&2
        return 1
    }

    if ! command -v swww >/dev/null 2>&1; then
        printf '%s\n' "swww is not installed. Run: sudo nixos-rebuild switch --flake ~/dotfiles" >&2
        command -v notify-send >/dev/null 2>&1 &&
            notify-send "Wallpaper picker" "Install swww with nixos-rebuild before applying wallpapers"
        return 1
    fi

    if ! swww query >/dev/null 2>&1; then
        swww-daemon >/dev/null 2>&1 &
        sleep 1
    fi

    swww img "$wallpaper" \
        --transition-type fade \
        --transition-fps 60 \
        --transition-duration 0.7
    printf '%s\n' "$wallpaper" > "$CURRENT_FILE"
}

if [[ "${1:-menu}" == "set" ]]; then
    [[ $# -ge 2 ]] || {
        printf 'Usage: %s set /path/to/wallpaper\n' "$0" >&2
        exit 2
    }
    apply_wallpaper "$2"
    exit
fi

if [[ "${1:-menu}" != "menu" ]]; then
    printf 'Usage: %s [menu|set /path/to/wallpaper]\n' "$0" >&2
    exit 2
fi

entries=()
for wallpaper in "${wallpapers[@]}"; do
    thumbnail="$(thumbnail_for "$wallpaper")"
    entries+=("$(basename "$wallpaper")\\0icon\\x1f$thumbnail")
done

selected="$(
    printf '%b\n' "${entries[@]}" |
        wofi --show dmenu --allow-images -I \
            --prompt "Select Wallpaper" \
            --width 650 --height 420 \
            --style "$STYLE_FILE" \
            --cache-file /dev/null
)" || true

[[ -n "$selected" ]] || exit 0

for wallpaper in "${wallpapers[@]}"; do
    if [[ "$selected" == "$(basename "$wallpaper")" ]]; then
        apply_wallpaper "$wallpaper"
        exit
    fi
done

printf 'Wallpaper selection was not found: %s\n' "$selected" >&2
exit 1
