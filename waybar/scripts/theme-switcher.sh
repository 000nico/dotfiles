#!/usr/bin/env bash
# Theme Switcher Script for Niri / Waybar / Kitty
# Supports: purple, orange, gruvbox

THEME_FILE="$HOME/.cache/current_system_theme"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"

apply_theme() {
    local theme="$1"
    echo "$theme" > "$THEME_FILE"

    case "$theme" in
        "gruvbox")
            sed -i 's|include themes/.*|include themes/gruvbox.conf|' "$KITTY_CONF" 2>/dev/null || true
            kitty @ set-colors --all ~/.config/kitty/themes/gruvbox.conf 2>/dev/null || true
            notify-send "Theme Switcher" "Switched to Gruvbox Theme 󰄛" -i "preferences-desktop-theme"
            ;;
        "orange"|"amber")
            sed -i 's|include themes/.*|include themes/orange.conf|' "$KITTY_CONF" 2>/dev/null || true
            kitty @ set-colors --all ~/.config/kitty/themes/orange.conf 2>/dev/null || true
            notify-send "Theme Switcher" "Switched to Amber Orange Theme 󱐋" -i "preferences-desktop-theme"
            ;;
        "purple"|*)
            sed -i 's|include themes/.*|include themes/purple.conf|' "$KITTY_CONF" 2>/dev/null || true
            kitty @ set-colors --all ~/.config/kitty/themes/purple.conf 2>/dev/null || true
            notify-send "Theme Switcher" "Switched to Purple Dark Theme 󰏘" -i "preferences-desktop-theme"
            ;;
    esac
}

get_current_theme() {
    [[ -f "$THEME_FILE" ]] && cat "$THEME_FILE" || echo "purple"
}

case "${1:-menu}" in
    "purple")
        apply_theme "purple"
        ;;
    "orange"|"amber")
        apply_theme "orange"
        ;;
    "gruvbox")
        apply_theme "gruvbox"
        ;;
    "toggle"|"next")
        curr=$(get_current_theme)
        case "$curr" in
            "purple") apply_theme "gruvbox" ;;
            "gruvbox") apply_theme "orange" ;;
            *) apply_theme "purple" ;;
        esac
        ;;
    "menu"|*)
        options="󰏘 Purple Dark\n󰄛 Gruvbox Dark\n󱐋 Amber Orange"
        chosen=$(echo -e "$options" | wofi --dmenu --prompt "  Select Theme" --insensitive --width 250 --height 180)
        case "$chosen" in
            *"Purple"*)  apply_theme "purple" ;;
            *"Gruvbox"*) apply_theme "gruvbox" ;;
            *"Amber"*)   apply_theme "orange" ;;
        esac
        ;;
esac
