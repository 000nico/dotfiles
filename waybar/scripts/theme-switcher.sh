#!/bin/bash
# Wallpaper Switcher Script — NixOS + Niri + swaybg
# Usage: theme-switcher.sh [next|random|restore|list]

WALLPAPER_DIR="$HOME/Pictures"
CURRENT_WALLPAPER_FILE="$HOME/.cache/current_wallpaper"

# Collect wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  notify-send "Wallpaper Switcher" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

get_current_index() {
  [[ -f "$CURRENT_WALLPAPER_FILE" ]] && cat "$CURRENT_WALLPAPER_FILE" || echo "0"
}

apply_wallpaper() {
  local wallpaper_path="$1"
  local index="$2"
  local wallpaper_name
  wallpaper_name=$(basename "$wallpaper_path")

  echo "$index" > "$CURRENT_WALLPAPER_FILE"

  # Apply wallpaper using swaybg (replace any existing instance)
  pkill swaybg 2>/dev/null || true
  swaybg -i "$wallpaper_path" -m fill &

  notify-send "Wallpaper Switcher" "Applied: $wallpaper_name"
}

restore_wallpaper() {
  local index=$(get_current_index)
  apply_wallpaper "${WALLPAPERS[$index]}" "$index"
}

case "${1:-next}" in
"next")
  next_index=$(( ($(get_current_index) + 1) % ${#WALLPAPERS[@]} ))
  apply_wallpaper "${WALLPAPERS[$next_index]}" "$next_index"
  ;;
"random")
  random_index=$(( RANDOM % ${#WALLPAPERS[@]} ))
  apply_wallpaper "${WALLPAPERS[$random_index]}" "$random_index"
  ;;
"restore")
  restore_wallpaper
  ;;
"list")
  selected=$(printf "%s\n" "${WALLPAPERS[@]##*/}" | wofi --dmenu --prompt "Choose Wallpaper" --insensitive)
  if [ -n "$selected" ]; then
    for i in "${!WALLPAPERS[@]}"; do
      if [[ "${WALLPAPERS[$i]##*/}" == "$selected" ]]; then
        apply_wallpaper "${WALLPAPERS[$i]}" "$i"
        break
      fi
    done
  else
    notify-send "Wallpaper Switcher" "No wallpaper selected."
  fi
  ;;
*)
  echo "Usage: $0 [next|random|restore|list]"
  exit 1
  ;;
esac
