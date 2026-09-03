#!/usr/bin/env bash

set -euo pipefail

output_dir="${XDG_PICTURES_DIR:-"$HOME/Pictures"}/Screenshots"
mkdir -p "$output_dir"
filename="$output_dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

case "${1:-region}" in
    region)
        geometry="$(slurp)"
        [ -n "$geometry" ]
        grim -g "$geometry" "$filename"
        ;;
    screen)
        grim "$filename"
        ;;
    *)
        printf 'Usage: %s [region|screen]\n' "$0" >&2
        exit 2
        ;;
esac

wl-copy --foreground --type image/png < "$filename" &
clipboard_pid=$!
disown "$clipboard_pid"
notify-send "Screenshot saved" "$(basename "$filename")"
