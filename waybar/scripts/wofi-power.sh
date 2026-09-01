#!/usr/bin/env bash
entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power Menu" --width 260 --height 220 --insensitive)

case "$selected" in
    *"Lock"*) loginctl lock-session ;;
    *"Logout"*) niri msg action quit --skip-confirmation 2>/dev/null || pkill -SIGTERM niri ;;
    *"Suspend"*) systemctl suspend ;;
    *"Reboot"*) systemctl reboot ;;
    *"Shutdown"*) systemctl poweroff ;;
esac
