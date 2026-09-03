#!/usr/bin/env bash

set -euo pipefail

selection="$(cliphist list | fuzzel --dmenu --width 72 --lines 12 --prompt 'clipboard> ' --cache-file /dev/null)"

if [ -n "$selection" ]; then
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' EXIT
    printf '%s\n' "$selection" | cliphist decode > "$tmp"
    magic="$(od -An -tx1 -N12 "$tmp" | tr -d ' \n')"
    case "$magic" in
        89504e470d0a1a0a*) mime="image/png" ;;
        ffd8ff*)           mime="image/jpeg" ;;
        52494646*)         mime="image/webp" ;;
        *)                 mime="text/plain" ;;
    esac
    wl-copy --type "$mime" < "$tmp"
fi
