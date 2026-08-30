#!/usr/bin/env bash
entries="Lock\nLogout\nSuspend\nReboot\nShutdown"

selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power Menu" --width 260 --height 220 --insensitive)

case "$selected" in
    *"Lock"*) loginctl lock-session ;;
    *"Logout"*) hyprctl dispatch exit ;;
    *"Suspend"*) systemctl suspend ;;
    *"Reboot"*) systemctl reboot ;;
    *"Shutdown"*) systemctl poweroff ;;
esac
