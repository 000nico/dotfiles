#!/usr/bin/env bash
set -euo pipefail

exec rofi -show drun -config "$HOME/.config/rofi/config.rasi" "$@"
