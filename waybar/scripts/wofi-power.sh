#!/usr/bin/env bash

# Power menu entries with nerd font icons — terminal style
entries=" Lock\n󰍃 Logout\n󰒲 Suspend\n󰑐 Reboot\n⏻ Shutdown"

selected=$(echo -e "$entries" | wofi \
    --dmenu \
    --prompt "  power" \
    --width 220 \
    --height 232 \
    --insensitive \
    --style /home/nico/.config/wofi/power.css \
    --cache-file /dev/null)

case "$selected" in
    *"Lock"*)     loginctl lock-session ;;
    *"Logout"*)   niri msg action quit --skip-confirmation 2>/dev/null || pkill -SIGTERM niri ;;
    *"Suspend"*)  systemctl suspend ;;
    *"Reboot"*)   systemctl reboot ;;
    *"Shutdown"*) systemctl poweroff ;;
esac
