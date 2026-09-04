#!/usr/bin/env bash
# Complete Theme Switcher Script for Niri Rice
# Synchronizes colors across: Niri, Waybar, Nautilus / GTK 4, GTK 3, Kitty, Mako, Wofi, Fuzzel, Yazi, Btop, Cava, ncspot, spotify-tui, Wallpaper
# Supported Themes: purple, pastel-blue, cute-pink

set -e

THEME_FILE="$HOME/.cache/current_system_theme"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"
PALETTE_DIR="$CONFIG_DIR/theme-palette"
GRUVBOX_WALLPAPER="$DOTFILES_DIR/assets/catto.jpg"
PASTEL_BLUE_WALLPAPER="$DOTFILES_DIR/assets/wallpapers/city.png"
PURPLE_WALLPAPER="$DOTFILES_DIR/assets/wallpapers/purple.jpg"
ORANGE_WALLPAPER="$DOTFILES_DIR/assets/wallpapers/orange.jpg"

mkdir -p "$HOME/.cache"

sync_file() {
    local src="$1"
    local rel="${src#$CONFIG_DIR/}"
    local dest="$DOTFILES_DIR/$rel"
    if [[ -d "$DOTFILES_DIR" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest" 2>/dev/null || true
    fi
}

set_wallpaper() {
    local wallpaper="$1"
    if [[ ! -f "$wallpaper" ]]; then
        echo "Wallpaper not found: $wallpaper" >&2
        return 0
    fi
    if [[ -f "$HOME/.cache/swaybg.pid" ]]; then
        read -r pid < "$HOME/.cache/swaybg.pid" || true
        [[ "$pid" =~ ^[0-9]+$ ]] && kill "$pid" 2>/dev/null || true
    fi
    pgrep -x swaybg 2>/dev/null | while read -r pid; do kill "$pid" 2>/dev/null || true; done
    sleep 1
    swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
    echo $! > "$HOME/.cache/swaybg.pid"
    printf '%s\n' "$wallpaper" > "$HOME/.cache/current_wallpaper"
}

update_niri_border() {
    local from="$1"
    local to="$2"
    local inactive="$3"
    local urgent="$4"
    python3 -c "
import re
path = '$CONFIG_DIR/niri/config.kdl'
with open(path, 'r') as f:
    c = f.read()
new_border = '''    border {
        width 2
        active-color \"$from\"
        inactive-color \"$inactive\"
        urgent-color \"$urgent\"
    }'''
c = re.sub(r'    border \{[^}]*\}', new_border, c)
with open(path, 'w') as f:
    f.write(c)
"
    sync_file "$CONFIG_DIR/niri/config.kdl"
}

apply_purple() {
    echo "Applying Purple Dark theme..."

    # 1. Niri border
    update_niri_border "#c084fc" "#7c3aed" "#1f1432aa" "#f87171"

    # 2. Waybar colors
    cat << WAYBAR > "$CONFIG_DIR/waybar/colors.css"
/* Waybar Purple Dark Theme */
@define-color background #080512;
@define-color second-background #18102c;
@define-color hover-background #261646;
@define-color active-background #3b1d6e;
@define-color text #e9d5ff;
@define-color subtext #b8a0d8;
@define-color borders #7c3aed;
@define-color focused #c084fc;
@define-color focused2 #d8b4fe;
@define-color color1 #a855f7;
@define-color color2 #818cf8;
@define-color color3 #86efac;
@define-color urgent #f87171;
WAYBAR
    sync_file "$CONFIG_DIR/waybar/colors.css"

    # 3. GTK 4 / Nautilus / Libadwaita
    cat << 'GTK4' > "$CONFIG_DIR/gtk-4.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) for GTK4 & Libadwaita / Nautilus */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Colors */
@define-color accent_color #c084fc;
@define-color accent_bg_color #7c3aed;
@define-color accent_fg_color #ffffff;

@define-color window_bg_color #080512;
@define-color window_fg_color #e9d5ff;

@define-color view_bg_color #05030a;
@define-color view_fg_color #e9d5ff;

@define-color headerbar_bg_color #0d081a;
@define-color headerbar_fg_color #e9d5ff;
@define-color headerbar_border_color #2a1548;

@define-color card_bg_color #0f0a1e;
@define-color card_fg_color #e9d5ff;
@define-color card_border_color #3b1d6e;

@define-color sidebar_bg_color #0a0616;
@define-color sidebar_fg_color #e9d5ff;
@define-color sidebar_border_color #2a1548;

@define-color popover_bg_color #0f0a1e;
@define-color popover_fg_color #e9d5ff;

/* Nautilus (Files) specific styling */
window.background, .background {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

/* Sidebar styling */
.sidebar, .navigation-sidebar, .sidebar-pane {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
    border-right: 1px solid @sidebar_border_color;
}

.navigation-sidebar row {
    padding: 6px 10px;
    margin: 2px 6px;
    border-left: 2px solid transparent;
}

.navigation-sidebar row:selected {
    background-color: rgba(124, 58, 237, 0.25);
    border-left: 2px solid #c084fc;
    color: #ffffff;
}

.navigation-sidebar row:hover:not(:selected) {
    background-color: rgba(24, 16, 44, 0.6);
}

/* View & Cards */
.view, .content-view, iconview {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

/* Keep Nautilus folder views spacious and readable. */
gridview > child,
listview > row {
    padding: 6px;
    border-radius: 4px;
}

gridview > child:hover,
listview > row:hover {
    background-color: rgba(142, 192, 124, 0.12);
}

gridview > child:selected,
listview > row:selected {
    background-color: rgba(142, 192, 124, 0.24);
    color: #ffffff;
}

/* Header bar */
headerbar {
    background-color: @headerbar_bg_color;
    border-bottom: 1px solid @headerbar_border_color;
    box-shadow: none;
}

/* Floating bar (status info in nautilus) */
.floating-bar {
    background-color: rgba(15, 10, 30, 0.9);
    border: 1px solid #7c3aed;
    color: #e9d5ff;
    padding: 4px 10px;
}

/* Buttons */
button {
    background-color: #140d24;
    border: 1px solid #2e1750;
    color: @window_fg_color;
    padding: 6px 12px;
}

button:hover {
    background-color: #22143c;
    border-color: #a855f7;
    color: #ffffff;
}

button:active, button:checked {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
    border-color: #c084fc;
}

/* Search bar and text entries */
entry, searchbar {
    background-color: #0d0818;
    border: 1px solid #3b1d6e;
    color: @window_fg_color;
}

entry:focus {
    border-color: #c084fc;
}

/* Scrollbars */
scrollbar slider {
    background-color: rgba(124, 58, 237, 0.4);
    min-width: 5px;
    min-height: 5px;
}

scrollbar slider:hover {
    background-color: rgba(192, 132, 252, 0.8);
}
GTK4
    sync_file "$CONFIG_DIR/gtk-4.0/gtk.css"

    # 4. GTK 3
    cat << 'GTK3' > "$CONFIG_DIR/gtk-3.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Color Palette - Dark Purple Aesthetic */
@define-color bg_color #080512;
@define-color fg_color #e9d5ff;
@define-color base_color #05030a;
@define-color text_color #e9d5ff;
@define-color selected_bg_color #7c3aed;
@define-color selected_fg_color #ffffff;
@define-color tooltip_bg_color #0f0a1e;
@define-color tooltip_fg_color #e9d5ff;
@define-color border_color #3b1d6e;
@define-color header_bg #0f0a1e;
@define-color sidebar_bg #0c0818;

window, window.background {
    background-color: @bg_color;
    color: @fg_color;
}

headerbar, .titlebar {
    background-color: @header_bg;
    color: @fg_color;
    border-bottom: 1px solid @border_color;
    box-shadow: none;
}

.sidebar, .sidebar list, .navigation-sidebar {
    background-color: @sidebar_bg;
    color: @fg_color;
    border-right: 1px solid @border_color;
}

button {
    background-color: #18102c;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 12px;
    transition: all 0.2s ease;
}

button:hover {
    background-color: #241642;
    border-color: #c084fc;
    color: #ffffff;
}

button:checked, button:active {
    background-color: @selected_bg_color;
    color: @selected_fg_color;
    border-color: #c084fc;
}

entry {
    background-color: #0f0a1e;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 10px;
}

entry:focus {
    border-color: #c084fc;
}

scrollbar slider {
    background-color: rgba(124, 58, 237, 0.4);
    min-width: 6px;
    min-height: 6px;
}

scrollbar slider:hover {
    background-color: rgba(192, 132, 252, 0.8);
}
GTK3
    sync_file "$CONFIG_DIR/gtk-3.0/gtk.css"
    sync_file "$CONFIG_DIR/gtk-3.0/settings.ini"
    sync_file "$CONFIG_DIR/gtk-4.0/settings.ini"

    # 5. Kitty
    sed -i 's|include themes/.*|include themes/purple.conf|' "$CONFIG_DIR/kitty/kitty.conf" 2>/dev/null || true
    kitty @ set-colors --all "$CONFIG_DIR/kitty/themes/purple.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/kitty/kitty.conf"

    # 6. Mako
    cat << 'MAKO' > "$CONFIG_DIR/mako/config"
max-visible=5
sort=-time
layer=overlay
anchor=top-right

width=340
height=110
margin=12
padding=10,14
border-size=1
border-radius=0
icons=1
max-icon-size=40
icon-location=left

font=JetBrainsMono Nerd Font 10
background-color=#080512f2
text-color=#e9d5ff
border-color=#c084fc
progress-color=source #c084fc

default-timeout=4000
ignore-timeout=1

on-button-left=dismiss
on-button-middle=dismiss-all
on-button-right=dismiss-all
on-touch=dismiss

[actionable]
border-color=#d8b4fe

[urgency=low]
background-color=#080512ea
border-color=#4c1d95
text-color=#b8a0d8
default-timeout=2500

[urgency=normal]
background-color=#080512f2
border-color=#c084fc
text-color=#e9d5ff
default-timeout=4000

[urgency=high]
background-color=#0d0518f8
border-color=#f87171
text-color=#fee2e2
default-timeout=7000
MAKO
    sync_file "$CONFIG_DIR/mako/config"

    # 7. Wofi
    cat << 'WOFI' > "$CONFIG_DIR/wofi/style.css"
/* Wofi - Purple Dark Theme */
window {
    margin: 0px;
    border: 2px solid #7c3aed;
    background-color: rgba(8, 5, 18, 0.96);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 12px 12px 6px 12px;
    padding: 8px 12px;
    border: none;
    border-bottom: 2px solid #4c1d95;
    border-radius: 0px;
    color: #e9d5ff;
    background-color: rgba(15, 10, 30, 0.6);
    caret-color: #c084fc;
    font-weight: 500;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
}

#input:focus {
    border-bottom: 2px solid #c084fc;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 4px 8px 10px 8px;
    background-color: transparent;
    orientation: horizontal;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 8px;
    color: #b8a0d8;
    font-weight: 400;
}

#img {
    margin-right: 8px;
    border-radius: 0px;
    min-width: 180px;
    min-height: 100px;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 2px 0px;
    min-width: 220px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(24, 16, 44, 0.8);
    border-left: 3px solid #7c3aed;
}

#entry:hover #text {
    color: #d8b4fe;
}

#entry:selected {
    background-color: rgba(35, 20, 65, 0.95);
    border-left: 3px solid #c084fc;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFI

    cat << 'WOFIP' > "$CONFIG_DIR/wofi/power.css"
/* Wofi Power - Purple Dark Theme */
window {
    margin: 0px;
    border: 2px solid #7c3aed;
    background-color: rgba(8, 5, 18, 0.97);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 10px 10px 4px 10px;
    padding: 6px 10px;
    border: none;
    border-bottom: 2px solid #4c1d95;
    border-radius: 0px;
    color: #c084fc;
    background-color: rgba(15, 10, 30, 0.5);
    caret-color: #c084fc;
    font-weight: 400;
    font-family: "JetBrainsMono Nerd Font", monospace;
}

#input:focus {
    border-bottom: 2px solid #c084fc;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 0px 4px 6px 4px;
    background-color: transparent;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 6px;
    color: #a855f7;
    font-weight: 400;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 1px 0px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(24, 16, 44, 0.8);
    border-left: 3px solid #7c3aed;
}

#entry:selected {
    background-color: rgba(35, 20, 65, 0.95);
    border-left: 3px solid #c084fc;
    color: #c084fc;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFIP
    sync_file "$CONFIG_DIR/wofi/style.css"
    sync_file "$CONFIG_DIR/wofi/power.css"

    # 8. Fuzzel
    cat << 'FUZZEL' > "$CONFIG_DIR/fuzzel/fuzzel.ini"
font=JetBrainsMono Nerd Font:size=11
prompt=""
icon-theme=Papirus-Dark
icons-enabled=no
terminal=kitty -e

lines=7
width=32
tabs=4
horizontal-pad=14
vertical-pad=10
inner-pad=6
line-height=20

layer=overlay
exit-on-keyboard-focus-loss=yes

[colors]
background=080512d9
text=e9d5ffff
prompt=86efacff
placeholder=6b4fa0ff
input=e9d5ffff
match=86efacff
selection=2a1a48e6
selection-text=c084fcff
selection-match=86efacff
border=7c3aedcc

[border]
width=1
radius=0
FUZZEL
    sync_file "$CONFIG_DIR/fuzzel/fuzzel.ini"

    # 9. Yazi
    cat << 'YAZI' > "$CONFIG_DIR/yazi/theme.toml"
[mgr]
cwd = { fg = "#c084fc", bold = true }
hovered = { fg = "#ffffff", bg = "#2d1a4e", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "#fde68a", bold = true, italic = true }
find_position = { fg = "#c084fc", bg = "reset", bold = true }
marker_selected = { fg = "#86efac", bg = "#86efac" }
marker_copied = { fg = "#fde68a", bg = "#fde68a" }
marker_cut = { fg = "#f87171", bg = "#f87171" }
tab_active = { fg = "#080512", bg = "#c084fc", bold = true }
tab_inactive = { fg = "#b8a0d8", bg = "#18102c" }
tab_width = 1
border_symbol = "│"
border_style = { fg = "#4c1d95" }

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "#18102c", bg = "#18102c" }
mode_normal = { fg = "#080512", bg = "#c084fc", bold = true }
mode_select = { fg = "#080512", bg = "#86efac", bold = true }
mode_unset = { fg = "#080512", bg = "#f87171", bold = true }
progress_label = { fg = "#ffffff", bold = true }
progress_normal = { fg = "#c084fc", bg = "#18102c" }
progress_error = { fg = "#f87171", bg = "#18102c" }
permissions_t = { fg = "#818cf8" }
permissions_r = { fg = "#fde68a" }
permissions_w = { fg = "#f87171" }
permissions_x = { fg = "#86efac" }
permissions_s = { fg = "#a855f7" }

[input]
border = { fg = "#c084fc" }
title = {}
value = {}
selected = { reversed = true }

[select]
border = { fg = "#c084fc" }
active = { fg = "#d8b4fe", bold = true }
inactive = {}

[which]
cols = 3
mask = { bg = "#080512" }
cand = { fg = "#c084fc" }
rest = { fg = "#b8a0d8" }
desc = { fg = "#e9d5ff" }
separator = " ➜ "
separator_style = { fg = "#4c1d95" }
YAZI
    sync_file "$CONFIG_DIR/yazi/theme.toml"

    # 10. Btop
    sed -i 's|color_theme = .*|color_theme = "purple"|' "$CONFIG_DIR/btop/btop.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/btop/btop.conf"

    # 11. Cava
    if [[ -f "$CONFIG_DIR/cava/config" ]]; then
        sed -i "s/gradient_color_1 = .*/gradient_color_1 = '#2d0a4e'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_2 = .*/gradient_color_2 = '#4c1d95'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_3 = .*/gradient_color_3 = '#6d28d9'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_4 = .*/gradient_color_4 = '#7c3aed'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_5 = .*/gradient_color_5 = '#8b5cf6'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_6 = .*/gradient_color_6 = '#a855f7'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_7 = .*/gradient_color_7 = '#c084fc'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_8 = .*/gradient_color_8 = '#e9d5ff'/" "$CONFIG_DIR/cava/config"
        sync_file "$CONFIG_DIR/cava/config"
    fi

    # 12. ncspot
    cat << 'NCSPOT' > "$CONFIG_DIR/ncspot/config.toml"
[theme]
background = "#080512"
primary = "#e9d5ff"
secondary = "#b8a0d8"
title = "#c084fc"
playing = "#86efac"
playing_selected = "#ffffff"
playing_bg = "#2d1a4e"
highlight = "#ffffff"
highlight_bg = "#3b1d6e"
error = "#f87171"
error_bg = "#080512"
statusbar = "#0f0a1e"
statusbar_progress = "#c084fc"
statusbar_subtext = "#b8a0d8"
statusbar_text = "#e9d5ff"
statusbar_bg = "#18102c"
cmdline = "#e9d5ff"
cmdline_bg = "#080512"
search_match = "#fde68a"
NCSPOT
    sync_file "$CONFIG_DIR/ncspot/config.toml"

    # 13. spotify-tui
    cat << 'SPT' > "$CONFIG_DIR/spotify-tui/config.yml"
theme:
  active: "#c084fc"
  banner: "#c084fc"
  error_border: "#f87171"
  error_text: "#f87171"
  hint: "#6b4fa0"
  hovered: "#7c3aed"
  inactive: "#1f1432"
  playbar_background: "#080512"
  playbar_progress: "#c084fc"
  playbar_text: "#e9d5ff"
  selected: "#86efac"
  text: "#e9d5ff"
  header: "#a78bfa"
SPT
    sync_file "$CONFIG_DIR/spotify-tui/config.yml"

    # 14. Wallpaper
    set_wallpaper "$PURPLE_WALLPAPER"
}

apply_orange() {
    echo "Applying Amber Orange theme..."

    # 1. Niri border
    update_niri_border "#ff8c00" "#e87820" "#2e1a0eaa" "#ff3d00"

    # 2. Waybar colors
    cat << 'WAYBAR' > "$CONFIG_DIR/waybar/colors.css"
/* Waybar Amber Orange Theme */
@define-color background #0a0704;
@define-color second-background #1e1109;
@define-color hover-background #2e1a0e;
@define-color active-background #4a2e1e;
@define-color text #f5dfc8;
@define-color subtext #d09070;
@define-color borders #e87820;
@define-color focused #ff8c00;
@define-color focused2 #ffaa40;
@define-color color1 #e87820;
@define-color color2 #d05820;
@define-color color3 #e8871a;
@define-color urgent #ff3d00;
WAYBAR
    sync_file "$CONFIG_DIR/waybar/colors.css"

    # 3. GTK 4 / Nautilus / Libadwaita
    cat << 'GTK4' > "$CONFIG_DIR/gtk-4.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) for GTK4 & Libadwaita / Nautilus */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Colors */
@define-color accent_color #ff8c00;
@define-color accent_bg_color #e87820;
@define-color accent_fg_color #ffffff;

@define-color window_bg_color #0a0704;
@define-color window_fg_color #f5dfc8;

@define-color view_bg_color #060402;
@define-color view_fg_color #f5dfc8;

@define-color headerbar_bg_color #140d07;
@define-color headerbar_fg_color #f5dfc8;
@define-color headerbar_border_color #3d2110;

@define-color card_bg_color #1a0f08;
@define-color card_fg_color #f5dfc8;
@define-color card_border_color #4a2814;

@define-color sidebar_bg_color #0f0905;
@define-color sidebar_fg_color #f5dfc8;
@define-color sidebar_border_color #3d2110;

@define-color popover_bg_color #1a0f08;
@define-color popover_fg_color #f5dfc8;

/* Nautilus (Files) specific styling */
window.background, .background {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

/* Sidebar styling */
.sidebar, .navigation-sidebar, .sidebar-pane {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
    border-right: 1px solid @sidebar_border_color;
}

.navigation-sidebar row {
    padding: 6px 10px;
    margin: 2px 6px;
    border-left: 2px solid transparent;
}

.navigation-sidebar row:selected {
    background-color: rgba(232, 120, 32, 0.25);
    border-left: 2px solid #ff8c00;
    color: #ffffff;
}

.navigation-sidebar row:hover:not(:selected) {
    background-color: rgba(35, 20, 10, 0.6);
}

/* View & Cards */
.view, .content-view, iconview {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

/* Header bar */
headerbar {
    background-color: @headerbar_bg_color;
    border-bottom: 1px solid @headerbar_border_color;
    box-shadow: none;
}

/* Floating bar (status info in nautilus) */
.floating-bar {
    background-color: rgba(26, 15, 8, 0.9);
    border: 1px solid #e87820;
    color: #f5dfc8;
    padding: 4px 10px;
}

/* Buttons */
button {
    background-color: #1a0f08;
    border: 1px solid #3d2110;
    color: @window_fg_color;
    padding: 6px 12px;
}

button:hover {
    background-color: #2e1a0e;
    border-color: #e87820;
    color: #ffffff;
}

button:active, button:checked {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
    border-color: #ff8c00;
}

/* Search bar and text entries */
entry, searchbar {
    background-color: #120b06;
    border: 1px solid #4a2814;
    color: @window_fg_color;
}

entry:focus {
    border-color: #ff8c00;
}

/* Scrollbars */
scrollbar slider {
    background-color: rgba(232, 120, 32, 0.4);
    min-width: 5px;
    min-height: 5px;
}

scrollbar slider:hover {
    background-color: rgba(255, 140, 0, 0.8);
}
GTK4
    sync_file "$CONFIG_DIR/gtk-4.0/gtk.css"

    # 4. GTK 3
    cat << 'GTK3' > "$CONFIG_DIR/gtk-3.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Color Palette - Amber Orange Aesthetic */
@define-color bg_color #0a0704;
@define-color fg_color #f5dfc8;
@define-color base_color #060402;
@define-color text_color #f5dfc8;
@define-color selected_bg_color #e87820;
@define-color selected_fg_color #ffffff;
@define-color tooltip_bg_color #1a0f08;
@define-color tooltip_fg_color #f5dfc8;
@define-color border_color #4a2814;
@define-color header_bg #1a0f08;
@define-color sidebar_bg #0f0905;

window, window.background {
    background-color: @bg_color;
    color: @fg_color;
}

headerbar, .titlebar {
    background-color: @header_bg;
    color: @fg_color;
    border-bottom: 1px solid @border_color;
    box-shadow: none;
}

.sidebar, .sidebar list, .navigation-sidebar {
    background-color: @sidebar_bg;
    color: @fg_color;
    border-right: 1px solid @border_color;
}

button {
    background-color: #1e1109;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 12px;
    transition: all 0.2s ease;
}

button:hover {
    background-color: #2e1a0e;
    border-color: #ff8c00;
    color: #ffffff;
}

button:checked, button:active {
    background-color: @selected_bg_color;
    color: @selected_fg_color;
    border-color: #ff8c00;
}

entry {
    background-color: #1a0f08;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 10px;
}

entry:focus {
    border-color: #ff8c00;
}

scrollbar slider {
    background-color: rgba(232, 120, 32, 0.4);
    min-width: 6px;
    min-height: 6px;
}

scrollbar slider:hover {
    background-color: rgba(255, 140, 0, 0.8);
}
GTK3
    sync_file "$CONFIG_DIR/gtk-3.0/gtk.css"

    # 5. Kitty
    sed -i 's|include themes/.*|include themes/orange.conf|' "$CONFIG_DIR/kitty/kitty.conf" 2>/dev/null || true
    kitty @ set-colors --all "$CONFIG_DIR/kitty/themes/orange.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/kitty/kitty.conf"

    # 6. Mako
    cat << 'MAKO' > "$CONFIG_DIR/mako/config"
max-visible=5
sort=-time
layer=overlay
anchor=top-right

width=340
height=110
margin=12
padding=10,14
border-size=1
border-radius=0
icons=1
max-icon-size=40
icon-location=left

font=JetBrainsMono Nerd Font 10
background-color=#0a0704f2
text-color=#f5dfc8
border-color=#ff8c00
progress-color=source #ff8c00

default-timeout=4000
ignore-timeout=1

on-button-left=dismiss
on-button-middle=dismiss-all
on-button-right=dismiss-all
on-touch=dismiss

[actionable]
border-color=#ffaa40

[urgency=low]
background-color=#0a0704ea
border-color=#4a2814
text-color=#d09070
default-timeout=2500

[urgency=normal]
background-color=#0a0704f2
border-color=#ff8c00
text-color=#f5dfc8
default-timeout=4000

[urgency=high]
background-color=#180804f8
border-color=#ff3d00
text-color=#fee2e2
default-timeout=7000
MAKO
    sync_file "$CONFIG_DIR/mako/config"

    # 7. Wofi
    cat << 'WOFI' > "$CONFIG_DIR/wofi/style.css"
/* Wofi - Amber Orange Theme */
window {
    margin: 0px;
    border: 2px solid #e87820;
    background-color: rgba(10, 7, 4, 0.96);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 12px 12px 6px 12px;
    padding: 8px 12px;
    border: none;
    border-bottom: 2px solid #4a2814;
    border-radius: 0px;
    color: #f5dfc8;
    background-color: rgba(26, 15, 8, 0.6);
    caret-color: #ff8c00;
    font-weight: 500;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
}

#input:focus {
    border-bottom: 2px solid #ff8c00;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 4px 8px 10px 8px;
    background-color: transparent;
    orientation: horizontal;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 8px;
    color: #d09070;
    font-weight: 400;
}

#img {
    margin-right: 8px;
    border-radius: 0px;
    min-width: 180px;
    min-height: 100px;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 2px 0px;
    min-width: 220px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(30, 17, 9, 0.8);
    border-left: 3px solid #e87820;
}

#entry:hover #text {
    color: #ffaa40;
}

#entry:selected {
    background-color: rgba(46, 26, 14, 0.95);
    border-left: 3px solid #ff8c00;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFI

    cat << 'WOFIP' > "$CONFIG_DIR/wofi/power.css"
/* Wofi Power - Amber Orange Theme */
window {
    margin: 0px;
    border: 2px solid #e87820;
    background-color: rgba(10, 7, 4, 0.97);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 10px 10px 4px 10px;
    padding: 6px 10px;
    border: none;
    border-bottom: 2px solid #4a2814;
    border-radius: 0px;
    color: #ff8c00;
    background-color: rgba(26, 15, 8, 0.5);
    caret-color: #ff8c00;
    font-weight: 400;
    font-family: "JetBrainsMono Nerd Font", monospace;
}

#input:focus {
    border-bottom: 2px solid #ff8c00;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 0px 4px 6px 4px;
    background-color: transparent;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 6px;
    color: #e87820;
    font-weight: 400;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 1px 0px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(30, 17, 9, 0.8);
    border-left: 3px solid #e87820;
}

#entry:selected {
    background-color: rgba(46, 26, 14, 0.95);
    border-left: 3px solid #ff8c00;
    color: #ff8c00;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFIP
    sync_file "$CONFIG_DIR/wofi/style.css"
    sync_file "$CONFIG_DIR/wofi/power.css"

    # 8. Fuzzel
    cat << 'FUZZEL' > "$CONFIG_DIR/fuzzel/fuzzel.ini"
font=JetBrainsMono Nerd Font:size=11
prompt=""
icon-theme=Papirus-Dark
icons-enabled=no
terminal=kitty -e

lines=7
width=32
tabs=4
horizontal-pad=14
vertical-pad=10
inner-pad=6
line-height=20

layer=overlay
exit-on-keyboard-focus-loss=yes

[colors]
background=0a0704d9
text=f5dfc8ff
prompt=e8871aff
placeholder=a87050ff
input=f5dfc8ff
match=e8871aff
selection=4a2e1ee6
selection-text=ff8c00ff
selection-match=e8871aff
border=e87820cc

[border]
width=1
radius=0
FUZZEL
    sync_file "$CONFIG_DIR/fuzzel/fuzzel.ini"

    # 9. Yazi
    cat << 'YAZI' > "$CONFIG_DIR/yazi/theme.toml"
[mgr]
cwd = { fg = "#ff8c00", bold = true }
hovered = { fg = "#ffffff", bg = "#2e1a0e", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "#e8a832", bold = true, italic = true }
find_position = { fg = "#ff8c00", bg = "reset", bold = true }
marker_selected = { fg = "#e8871a", bg = "#e8871a" }
marker_copied = { fg = "#e8a832", bg = "#e8a832" }
marker_cut = { fg = "#e84040", bg = "#e84040" }
tab_active = { fg = "#0a0704", bg = "#ff8c00", bold = true }
tab_inactive = { fg = "#d09070", bg = "#1e1109" }
tab_width = 1
border_symbol = "│"
border_style = { fg = "#a84510" }

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "#1e1109", bg = "#1e1109" }
mode_normal = { fg = "#0a0704", bg = "#ff8c00", bold = true }
mode_select = { fg = "#0a0704", bg = "#e8871a", bold = true }
mode_unset = { fg = "#0a0704", bg = "#e84040", bold = true }
progress_label = { fg = "#ffffff", bold = true }
progress_normal = { fg = "#ff8c00", bg = "#1e1109" }
progress_error = { fg = "#e84040", bg = "#1e1109" }
permissions_t = { fg = "#d05820" }
permissions_r = { fg = "#e8a832" }
permissions_w = { fg = "#e84040" }
permissions_x = { fg = "#e8871a" }
permissions_s = { fg = "#c04010" }

[input]
border = { fg = "#ff8c00" }
title = {}
value = {}
selected = { reversed = true }

[select]
border = { fg = "#ff8c00" }
active = { fg = "#ffaa40", bold = true }
inactive = {}

[which]
cols = 3
mask = { bg = "#0a0704" }
cand = { fg = "#ff8c00" }
rest = { fg = "#d09070" }
desc = { fg = "#f5dfc8" }
separator = " ➜ "
separator_style = { fg = "#a84510" }
YAZI
    sync_file "$CONFIG_DIR/yazi/theme.toml"

    # 10. Btop
    sed -i 's|color_theme = .*|color_theme = "orange"|' "$CONFIG_DIR/btop/btop.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/btop/btop.conf"

    # 11. Cava
    if [[ -f "$CONFIG_DIR/cava/config" ]]; then
        sed -i "s/gradient_color_1 = .*/gradient_color_1 = '#2e1005'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_2 = .*/gradient_color_2 = '#4a1a08'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_3 = .*/gradient_color_3 = '#7a280a'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_4 = .*/gradient_color_4 = '#a84510'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_5 = .*/gradient_color_5 = '#d05820'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_6 = .*/gradient_color_6 = '#e87820'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_7 = .*/gradient_color_7 = '#ff8c00'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_8 = .*/gradient_color_8 = '#f5dfc8'/" "$CONFIG_DIR/cava/config"
        sync_file "$CONFIG_DIR/cava/config"
    fi

    # 12. ncspot
    cat << 'NCSPOT' > "$CONFIG_DIR/ncspot/config.toml"
[theme]
background = "#0a0704"
primary = "#f5dfc8"
secondary = "#d09070"
title = "#ff8c00"
playing = "#e8871a"
playing_selected = "#ffffff"
playing_bg = "#2e1a0e"
highlight = "#ffffff"
highlight_bg = "#4a2e1e"
error = "#e84040"
error_bg = "#0a0704"
statusbar = "#1a0f08"
statusbar_progress = "#ff8c00"
statusbar_subtext = "#d09070"
statusbar_text = "#f5dfc8"
statusbar_bg = "#1e1109"
cmdline = "#f5dfc8"
cmdline_bg = "#0a0704"
search_match = "#e8a832"
NCSPOT
    sync_file "$CONFIG_DIR/ncspot/config.toml"

    # 13. spotify-tui
    cat << 'SPT' > "$CONFIG_DIR/spotify-tui/config.yml"
theme:
  active: "#ff8c00"
  banner: "#ff8c00"
  error_border: "#e84040"
  error_text: "#e84040"
  hint: "#a87050"
  hovered: "#e87820"
  inactive: "#2e1a0e"
  playbar_background: "#0a0704"
  playbar_progress: "#ff8c00"
  playbar_text: "#f5dfc8"
  selected: "#e8871a"
  text: "#f5dfc8"
  header: "#d05820"
SPT
    sync_file "$CONFIG_DIR/spotify-tui/config.yml"

    # 14. Wallpaper
    set_wallpaper "$ORANGE_WALLPAPER"
}

apply_gruvbox() {
    echo "Applying Gruvbox Dark theme..."
    source "$PALETTE_DIR/gruvbox.sh"

    # 1. Niri border
    update_niri_border "$GRUVBOX_AQUA" "$GRUVBOX_AQUA" "${GRUVBOX_HOVER}aa" "$GRUVBOX_RED"

    # 2. Waybar colors
    cat << WAYBAR > "$CONFIG_DIR/waybar/colors.css"
/* Waybar Gruvbox Dark Theme */
@define-color background ${GRUVBOX_BG};
@define-color second-background ${GRUVBOX_SURFACE};
@define-color hover-background ${GRUVBOX_HOVER};
@define-color active-background ${GRUVBOX_ACTIVE};
@define-color text ${GRUVBOX_TEXT};
@define-color subtext ${GRUVBOX_MUTED};
@define-color borders ${GRUVBOX_AQUA};
@define-color focused ${GRUVBOX_AQUA};
@define-color focused2 ${GRUVBOX_BLUE};
@define-color color1 ${GRUVBOX_AQUA};
@define-color color2 ${GRUVBOX_BLUE};
@define-color color3 ${GRUVBOX_GREEN};
@define-color urgent ${GRUVBOX_RED};
WAYBAR
    sync_file "$CONFIG_DIR/waybar/colors.css"
    sync_file "$PALETTE_DIR/gruvbox.sh"

    # 3. GTK 4 / Nautilus / Libadwaita
    cat << 'GTK4' > "$CONFIG_DIR/gtk-4.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) for GTK4 & Libadwaita / Nautilus */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Colors */
@define-color accent_color #8ec07c;
@define-color accent_bg_color #689d6a;
@define-color accent_fg_color #ffffff;

@define-color window_bg_color #1d2021;
@define-color window_fg_color #ebdbb2;

@define-color view_bg_color #141617;
@define-color view_fg_color #ebdbb2;

@define-color headerbar_bg_color #282828;
@define-color headerbar_fg_color #ebdbb2;
@define-color headerbar_border_color #3c3836;

@define-color card_bg_color #282828;
@define-color card_fg_color #ebdbb2;
@define-color card_border_color #504945;

@define-color sidebar_bg_color #202324;
@define-color sidebar_fg_color #ebdbb2;
@define-color sidebar_border_color #3c3836;

@define-color popover_bg_color #282828;
@define-color popover_fg_color #ebdbb2;

/* Nautilus (Files) specific styling */
/* Keep Nautilus folder views spacious and readable. */
gridview > child,
listview > row {
    padding: 6px;
    border-radius: 4px;
}

gridview > child:hover,
listview > row:hover {
    background-color: rgba(142, 192, 124, 0.12);
}

gridview > child:selected,
listview > row:selected {
    background-color: rgba(142, 192, 124, 0.24);
    color: #ffffff;
}

window.background, .background {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

/* Sidebar styling */
.sidebar, .navigation-sidebar, .sidebar-pane {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
    border-right: 1px solid @sidebar_border_color;
}

.navigation-sidebar row {
    padding: 6px 10px;
    margin: 2px 6px;
    border-left: 2px solid transparent;
}

.navigation-sidebar row:selected {
    background-color: rgba(142, 192, 124, 0.25);
    border-left: 2px solid #8ec07c;
    color: #ffffff;
}

.navigation-sidebar row:hover:not(:selected) {
    background-color: rgba(60, 56, 54, 0.6);
}

/* View & Cards */
.view, .content-view, iconview {
    background-color: @view_bg_color;
    color: @view_fg_color;
}

/* Header bar */
headerbar {
    background-color: @headerbar_bg_color;
    border-bottom: 1px solid @headerbar_border_color;
    box-shadow: none;
}

/* Floating bar (status info in nautilus) */
.floating-bar {
    background-color: rgba(40, 40, 40, 0.9);
    border: 1px solid #8ec07c;
    color: #ebdbb2;
    padding: 4px 10px;
}

/* Buttons */
button {
    background-color: #282828;
    border: 1px solid #3c3836;
    color: @window_fg_color;
    padding: 6px 12px;
}

button:hover {
    background-color: #3c3836;
    border-color: #8ec07c;
    color: #ffffff;
}

button:active, button:checked {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
    border-color: #8ec07c;
}

/* Search bar and text entries */
entry, searchbar {
    background-color: #242728;
    border: 1px solid #504945;
    color: @window_fg_color;
}

entry:focus {
    border-color: #8ec07c;
}

/* Scrollbars */
scrollbar slider {
    background-color: rgba(142, 192, 124, 0.4);
    min-width: 5px;
    min-height: 5px;
}

scrollbar slider:hover {
    background-color: rgba(142, 192, 124, 0.8);
}
GTK4
    sync_file "$CONFIG_DIR/gtk-4.0/gtk.css"

    # 4. GTK 3
    cat << 'GTK3' > "$CONFIG_DIR/gtk-3.0/gtk.css"
/* Global Sharp Square Aesthetic (radius 0) */
* {
    border-radius: 0px;
    -gtk-outline-radius: 0px;
}

/* Color Palette - Gruvbox Dark Aesthetic */
@define-color bg_color #1d2021;
@define-color fg_color #ebdbb2;
@define-color base_color #141617;
@define-color text_color #ebdbb2;
@define-color selected_bg_color #8ec07c;
@define-color selected_fg_color #ffffff;
@define-color tooltip_bg_color #282828;
@define-color tooltip_fg_color #ebdbb2;
@define-color border_color #504945;
@define-color header_bg #282828;
@define-color sidebar_bg #202324;

window, window.background {
    background-color: @bg_color;
    color: @fg_color;
}

headerbar, .titlebar {
    background-color: @header_bg;
    color: @fg_color;
    border-bottom: 1px solid @border_color;
    box-shadow: none;
}

.sidebar, .sidebar list, .navigation-sidebar {
    background-color: @sidebar_bg;
    color: @fg_color;
    border-right: 1px solid @border_color;
}

button {
    background-color: #282828;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 12px;
    transition: all 0.2s ease;
}

button:hover {
    background-color: #3c3836;
    border-color: #8ec07c;
    color: #ffffff;
}

button:checked, button:active {
    background-color: @selected_bg_color;
    color: @selected_fg_color;
    border-color: #fabd2f;
}

entry {
    background-color: #282828;
    color: @fg_color;
    border: 1px solid @border_color;
    padding: 6px 10px;
}

entry:focus {
    border-color: #8ec07c;
}

scrollbar slider {
    background-color: rgba(142, 192, 124, 0.4);
    min-width: 6px;
    min-height: 6px;
}

scrollbar slider:hover {
    background-color: rgba(142, 192, 124, 0.8);
}
GTK3
    sync_file "$CONFIG_DIR/gtk-3.0/gtk.css"

    # 5. Kitty
    sed -i 's|include themes/.*|include themes/gruvbox.conf|' "$CONFIG_DIR/kitty/kitty.conf" 2>/dev/null || true
    kitty @ set-colors --all "$CONFIG_DIR/kitty/themes/gruvbox.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/kitty/kitty.conf"

    # 6. Mako
    cat << 'MAKO' > "$CONFIG_DIR/mako/config"
max-visible=5
sort=-time
layer=overlay
anchor=top-right

width=340
height=110
margin=12
padding=10,14
border-size=1
border-radius=0
icons=1
max-icon-size=40
icon-location=left

font=JetBrainsMono Nerd Font 10
background-color=#1d2021f2
text-color=#ebdbb2
border-color=#8ec07c
progress-color=source #8ec07c

default-timeout=4000
ignore-timeout=1

on-button-left=dismiss
on-button-middle=dismiss-all
on-button-right=dismiss-all
on-touch=dismiss

[actionable]
border-color=#fabd2f

[urgency=low]
background-color=#1d2021ea
border-color=#504945
text-color=#a89984
default-timeout=2500

[urgency=normal]
background-color=#1d2021f2
border-color=#8ec07c
text-color=#ebdbb2
default-timeout=4000

[urgency=high]
background-color=#281414f8
border-color=#fb4934
text-color=#fee2e2
default-timeout=7000
MAKO
    sync_file "$CONFIG_DIR/mako/config"

    # 7. Wofi
    cat << 'WOFI' > "$CONFIG_DIR/wofi/style.css"
/* Wofi - Gruvbox Dark Theme */
window {
    margin: 0px;
    border: 2px solid #8ec07c;
    background-color: rgba(29, 32, 33, 0.96);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 12px 12px 6px 12px;
    padding: 8px 12px;
    border: none;
    border-bottom: 2px solid #504945;
    border-radius: 0px;
    color: #ebdbb2;
    background-color: rgba(40, 40, 40, 0.6);
    caret-color: #8ec07c;
    font-weight: 500;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
}

#input:focus {
    border-bottom: 2px solid #8ec07c;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 4px 8px 10px 8px;
    background-color: transparent;
    orientation: horizontal;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 8px;
    color: #a89984;
    font-weight: 400;
}

#img {
    margin-right: 8px;
    border-radius: 0px;
    min-width: 180px;
    min-height: 100px;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 2px 0px;
    min-width: 220px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(50, 48, 47, 0.8);
    border-left: 3px solid #8ec07c;
}

#entry:hover #text {
    color: #fabd2f;
}

#entry:selected {
    background-color: rgba(60, 56, 54, 0.95);
    border-left: 3px solid #8ec07c;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFI

    cat << 'WOFIP' > "$CONFIG_DIR/wofi/power.css"
/* Wofi Power - Gruvbox Dark Theme */
window {
    margin: 0px;
    border: 2px solid #8ec07c;
    background-color: rgba(29, 32, 33, 0.97);
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.8);
}

#input {
    margin: 10px 10px 4px 10px;
    padding: 6px 10px;
    border: none;
    border-bottom: 2px solid #504945;
    border-radius: 0px;
    color: #8ec07c;
    background-color: rgba(40, 40, 40, 0.5);
    caret-color: #8ec07c;
    font-weight: 400;
    font-family: "JetBrainsMono Nerd Font", monospace;
}

#input:focus {
    border-bottom: 2px solid #8ec07c;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 0px 4px 6px 4px;
    background-color: transparent;
}

#outer-box {
    margin: 0px;
    background-color: transparent;
}

#scroll {
    margin: 2px 0px;
    border: none;
}

#text {
    margin: 2px 6px;
    color: #8ec07c;
    font-weight: 400;
}

#entry {
    padding: 8px 12px;
    border-radius: 0px;
    margin: 1px 0px;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
}

#entry:hover {
    background-color: rgba(50, 48, 47, 0.8);
    border-left: 3px solid #8ec07c;
}

#entry:selected {
    background-color: rgba(60, 56, 54, 0.95);
    border-left: 3px solid #8ec07c;
    color: #8ec07c;
}

#entry:selected #text {
    color: #ffffff;
    font-weight: 600;
}
WOFIP
    sync_file "$CONFIG_DIR/wofi/style.css"
    sync_file "$CONFIG_DIR/wofi/power.css"

    # 8. Fuzzel
    cat << 'FUZZEL' > "$CONFIG_DIR/fuzzel/fuzzel.ini"
font=JetBrainsMono Nerd Font:size=11
prompt=""
icon-theme=Papirus-Dark
icons-enabled=no
terminal=kitty -e

lines=7
width=32
tabs=4
horizontal-pad=14
vertical-pad=10
inner-pad=6
line-height=20

layer=overlay
exit-on-keyboard-focus-loss=yes

[colors]
background=1d2021d9
text=ebdbb2ff
prompt=fe8019ff
placeholder=928374ff
input=ebdbb2ff
match=fabd2fff
selection=3c3836e6
selection-text=fe8019ff
selection-match=fabd2fff
border=fe8019cc

[border]
width=1
radius=0
FUZZEL
    sync_file "$CONFIG_DIR/fuzzel/fuzzel.ini"

    # 9. Yazi
    cat << 'YAZI' > "$CONFIG_DIR/yazi/theme.toml"
[mgr]
cwd = { fg = "#8ec07c", bold = true }
hovered = { fg = "#ffffff", bg = "#3c3836", bold = true }
preview_hovered = { underline = true }
find_keyword = { fg = "#fabd2f", bold = true, italic = true }
find_position = { fg = "#8ec07c", bg = "reset", bold = true }
marker_selected = { fg = "#b8bb26", bg = "#b8bb26" }
marker_copied = { fg = "#8ec07c", bg = "#8ec07c" }
marker_cut = { fg = "#fb4934", bg = "#fb4934" }
tab_active = { fg = "#1d2021", bg = "#8ec07c", bold = true }
tab_inactive = { fg = "#a89984", bg = "#282828" }
tab_width = 1
border_symbol = "│"
border_style = { fg = "#504945" }

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "#282828", bg = "#282828" }
mode_normal = { fg = "#1d2021", bg = "#8ec07c", bold = true }
mode_select = { fg = "#1d2021", bg = "#b8bb26", bold = true }
mode_unset = { fg = "#1d2021", bg = "#fb4934", bold = true }
progress_label = { fg = "#ffffff", bold = true }
progress_normal = { fg = "#8ec07c", bg = "#282828" }
progress_error = { fg = "#fb4934", bg = "#282828" }
permissions_t = { fg = "#83a598" }
permissions_r = { fg = "#8ec07c" }
permissions_w = { fg = "#fb4934" }
permissions_x = { fg = "#b8bb26" }
permissions_s = { fg = "#d3869b" }

[input]
border = { fg = "#8ec07c" }
title = {}
value = {}
selected = { reversed = true }

[select]
border = { fg = "#8ec07c" }
active = { fg = "#fabd2f", bold = true }
inactive = {}

[which]
cols = 3
mask = { bg = "#1d2021" }
cand = { fg = "#8ec07c" }
rest = { fg = "#a89984" }
desc = { fg = "#ebdbb2" }
separator = " ➜ "
separator_style = { fg = "#504945" }
YAZI
    sync_file "$CONFIG_DIR/yazi/theme.toml"

    # 10. Btop
    sed -i 's|color_theme = .*|color_theme = "gruvbox"|' "$CONFIG_DIR/btop/btop.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/btop/btop.conf"

    # 11. Cava
    if [[ -f "$CONFIG_DIR/cava/config" ]]; then
        sed -i "s/gradient_color_1 = .*/gradient_color_1 = '#282828'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_2 = .*/gradient_color_2 = '#3c3836'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_3 = .*/gradient_color_3 = '#504945'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_4 = .*/gradient_color_4 = '#689d6a'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_5 = .*/gradient_color_5 = '#8ec07c'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_6 = .*/gradient_color_6 = '#fabd2f'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_7 = .*/gradient_color_7 = '#b8bb26'/" "$CONFIG_DIR/cava/config"
        sed -i "s/gradient_color_8 = .*/gradient_color_8 = '#ebdbb2'/" "$CONFIG_DIR/cava/config"
        sync_file "$CONFIG_DIR/cava/config"
    fi

    # 12. ncspot
    cat << 'NCSPOT' > "$CONFIG_DIR/ncspot/config.toml"
[theme]
background = "#1d2021"
primary = "#ebdbb2"
secondary = "#a89984"
title = "#8ec07c"
playing = "#b8bb26"
playing_selected = "#ffffff"
playing_bg = "#3c3836"
highlight = "#ffffff"
highlight_bg = "#504945"
error = "#fb4934"
error_bg = "#1d2021"
statusbar = "#282828"
statusbar_progress = "#8ec07c"
statusbar_subtext = "#a89984"
statusbar_text = "#ebdbb2"
statusbar_bg = "#282828"
cmdline = "#ebdbb2"
cmdline_bg = "#1d2021"
search_match = "#fabd2f"
NCSPOT
    sync_file "$CONFIG_DIR/ncspot/config.toml"

    # 13. spotify-tui
    cat << 'SPT' > "$CONFIG_DIR/spotify-tui/config.yml"
theme:
  active: "#8ec07c"
  banner: "#8ec07c"
  error_border: "#fb4934"
  error_text: "#fb4934"
  hint: "#a89984"
  hovered: "#fabd2f"
  inactive: "#3c3836"
  playbar_background: "#1d2021"
  playbar_progress: "#8ec07c"
  playbar_text: "#ebdbb2"
  selected: "#b8bb26"
  text: "#ebdbb2"
  header: "#83a598"
SPT
    sync_file "$CONFIG_DIR/spotify-tui/config.yml"

    # Keep generated application themes aligned with the shared palette.
    local palette_targets=(
        "$CONFIG_DIR/gtk-3.0/gtk.css"
        "$CONFIG_DIR/gtk-4.0/gtk.css"
        "$CONFIG_DIR/wofi/style.css"
        "$CONFIG_DIR/wofi/power.css"
        "$CONFIG_DIR/mako/config"
        "$CONFIG_DIR/kitty/themes/gruvbox.conf"
        "$CONFIG_DIR/fuzzel/fuzzel.ini"
        "$CONFIG_DIR/yazi/theme.toml"
        "$CONFIG_DIR/ncspot/config.toml"
        "$CONFIG_DIR/spotify-tui/config.yml"
    )
    for target in "${palette_targets[@]}"; do
        [[ -f "$target" ]] || continue
        sed -i \
            -e "s/#fe8019/${GRUVBOX_AQUA}/g" \
            -e "s/#d65d0e/${GRUVBOX_HOVER}/g" \
            -e "s/#fabd2f/${GRUVBOX_AQUA}/g" \
            "$target"
        sync_file "$target"
    done

}

recolor_theme_files() {
    local theme="$1"
    local target
    local -a targets=(
        "$CONFIG_DIR/gtk-3.0/gtk.css"
        "$CONFIG_DIR/gtk-4.0/gtk.css"
        "$CONFIG_DIR/wofi/style.css"
        "$CONFIG_DIR/wofi/power.css"
        "$CONFIG_DIR/mako/config"
        "$CONFIG_DIR/fuzzel/fuzzel.ini"
        "$CONFIG_DIR/yazi/theme.toml"
        "$CONFIG_DIR/ncspot/config.toml"
        "$CONFIG_DIR/spotify-tui/config.yml"
        "$CONFIG_DIR/cava/config"
    )

    for target in "${targets[@]}"; do
        [[ -f "$target" ]] || continue
        if [[ "$theme" == "pastel-blue" ]]; then
            sed -i \
                -e 's/#141617/#18202b/g' -e 's/#1d2021/#18202b/g' \
                -e 's/#282828/#243242/g' -e 's/#32302f/#30485a/g' \
                -e 's/#3c3836/#426176/g' -e 's/#ebdbb2/#d9f0ff/g' \
                -e 's/#d5c4a1/#b7e4f9/g' -e 's/#a89984/#9bb9cc/g' \
                -e 's/#fabd2f/#9bdcff/g' -e 's/#fb4934/#ff8fa3/g' \
                -e 's/#b8bb26/#a9e6cf/g' -e 's/#8ec07c/#8fc8e8/g' \
                -e 's/#83a598/#b7e4f9/g' -e 's/#d3869b/#9bdcff/g' \
                -e 's/#689d6a/#426176/g' "$target"
        else
            sed -i \
                -e 's/#141617/#241b29/g' -e 's/#1d2021/#261b29/g' \
                -e 's/#282828/#38243b/g' -e 's/#32302f/#49304a/g' \
                -e 's/#3c3836/#543553/g' -e 's/#ebdbb2/#ffe8f3/g' \
                -e 's/#d5c4a1/#f2c9dc/g' -e 's/#a89984/#d8b4c7/g' \
                -e 's/#fabd2f/#ffafd0/g' -e 's/#fb4934/#ff759f/g' \
                -e 's/#b8bb26/#b8f2e6/g' -e 's/#8ec07c/#f5a6c8/g' \
                -e 's/#83a598/#e7b7ff/g' -e 's/#d3869b/#f3a8c8/g' \
                -e 's/#689d6a/#70476d/g' "$target"
        fi
        sync_file "$target"
    done
}

write_wofi_launcher_style() {
    local theme="$1"
    local background surface hover accent text muted
    local window_bg input_bg hover_bg selected_bg

    case "$theme" in
        purple)
            background="#080512"; surface="#18102c"; hover="#261646"
            accent="#c084fc"; text="#e9d5ff"; muted="#b8a0d8"
            window_bg="rgba(8, 5, 18, 0.92)"; input_bg="rgba(24, 16, 44, 0.86)"
            hover_bg="rgba(38, 22, 70, 0.88)"; selected_bg="rgba(24, 16, 44, 0.92)"
            ;;
        pastel-blue)
            background="#18202b"; surface="#243242"; hover="#30485a"
            accent="#9bdcff"; text="#d9f0ff"; muted="#9bb9cc"
            window_bg="rgba(24, 32, 43, 0.92)"; input_bg="rgba(36, 50, 66, 0.86)"
            hover_bg="rgba(48, 72, 90, 0.88)"; selected_bg="rgba(36, 50, 66, 0.92)"
            ;;
        cute-pink)
            background="#261b29"; surface="#38243b"; hover="#543553"
            accent="#ffafd0"; text="#ffe8f3"; muted="#d8b4c7"
            window_bg="rgba(38, 27, 41, 0.92)"; input_bg="rgba(56, 36, 59, 0.86)"
            hover_bg="rgba(84, 53, 83, 0.88)"; selected_bg="rgba(56, 36, 59, 0.92)"
            ;;
        *)
            echo "Unknown Wofi theme: $theme" >&2
            return 2
            ;;
    esac

    cat > "$CONFIG_DIR/wofi/style.css" <<CSS
window {
    margin: 0px;
    border: 2px solid $accent;
    background-color: $window_bg;
    border-radius: 0px;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 14px;
    box-shadow: 0 10px 35px rgba(0, 0, 0, 0.55);
}

#input {
    margin: 12px 14px 8px 14px;
    padding: 10px 12px;
    border: 1px solid $surface;
    border-radius: 0px;
    color: $text;
    background-color: $input_bg;
    caret-color: $accent;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 14px;
}

#input:focus {
    border-color: $accent;
    box-shadow: none;
    outline: none;
}

#inner-box {
    margin: 4px 14px 12px 14px;
    background-color: transparent;
}

#outer-box,
#scroll {
    margin: 0px;
    border: none;
    background-color: transparent;
}

#text {
    margin: 3px 12px;
    color: $muted;
}

#entry {
    padding: 9px 12px;
    margin: 2px 0px;
    border: 1px solid transparent;
    border-radius: 0px;
}

#entry:hover {
    background-color: $hover_bg;
    border-color: $accent;
}

#entry:hover #text,
#entry:selected #text {
    color: $text;
}

#entry:selected {
    background-color: $selected_bg;
    border-color: $accent;
}
CSS
    sync_file "$CONFIG_DIR/wofi/style.css"
}

apply_pastel_blue() {
    apply_gruvbox
    update_niri_border "#8fc8e8" "#8fc8e8" "#30485aaa" "#ff8fa3"
    cat << 'WAYBAR' > "$CONFIG_DIR/waybar/colors.css"
@define-color background #18202b;
@define-color second-background #243242;
@define-color hover-background #30485a;
@define-color active-background #426176;
@define-color text #d9f0ff;
@define-color subtext #9bb9cc;
@define-color borders #9bdcff;
@define-color focused #8fc8e8;
@define-color focused2 #b7e4f9;
@define-color color1 #8fc8e8;
@define-color color2 #b7e4f9;
@define-color color3 #a9e6cf;
@define-color urgent #ff8fa3;
WAYBAR
    sync_file "$CONFIG_DIR/waybar/colors.css"
    recolor_theme_files pastel-blue
    sed -i 's/color_theme = .*/color_theme = "Default"/' "$CONFIG_DIR/btop/btop.conf"
    sed -i 's|include themes/.*|include themes/pastel-blue.conf|' "$CONFIG_DIR/kitty/kitty.conf"
    kitty @ set-colors --all "$CONFIG_DIR/kitty/themes/pastel-blue.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/kitty/kitty.conf"
}

apply_cute_pink() {
    apply_gruvbox
    update_niri_border "#ffafd0" "#ffafd0" "#543553aa" "#ff759f"
    cat << 'WAYBAR' > "$CONFIG_DIR/waybar/colors.css"
@define-color background #261b29;
@define-color second-background #38243b;
@define-color hover-background #543553;
@define-color active-background #70476d;
@define-color text #ffe8f3;
@define-color subtext #d8b4c7;
@define-color borders #f3a8c8;
@define-color focused #ffafd0;
@define-color focused2 #ffd1e3;
@define-color color1 #f5a6c8;
@define-color color2 #e7b7ff;
@define-color color3 #b8f2e6;
@define-color urgent #ff759f;
WAYBAR
    sync_file "$CONFIG_DIR/waybar/colors.css"
    sed -i 's/color_theme = .*/color_theme = "Default"/' "$CONFIG_DIR/btop/btop.conf"
    recolor_theme_files cute-pink
    sed -i 's|include themes/.*|include themes/cute-pink.conf|' "$CONFIG_DIR/kitty/kitty.conf"
    kitty @ set-colors --all "$CONFIG_DIR/kitty/themes/cute-pink.conf" 2>/dev/null || true
    sync_file "$CONFIG_DIR/kitty/kitty.conf"
}

reload_all() {
    local theme_name="$1"
    local icon="$2"

    # Reload Waybar
    pkill -SIGUSR2 waybar 2>/dev/null || true

    # Reload Mako
    makoctl reload 2>/dev/null || true

    # Touch GTK CSS for Nautilus & GTK apps live update
    touch "$CONFIG_DIR/gtk-4.0/gtk.css" "$CONFIG_DIR/gtk-3.0/gtk.css" 2>/dev/null || true

    # Send desktop notification
    notify-send "Theme Switcher" "Switched to $theme_name Theme $icon" -i "preferences-desktop-theme"
}

apply_theme() {
    local theme="$1"

    case "$theme" in
        "pastel-blue")
            apply_pastel_blue
            echo "$theme" > "$THEME_FILE"
            reload_all "Pastel Blue" "󰔏"
            ;;
        "purple")
            apply_purple
            echo "$theme" > "$THEME_FILE"
            reload_all "Purple Dark" "󰏘"
            ;;
        "cute-pink")
            apply_cute_pink
            echo "$theme" > "$THEME_FILE"
            reload_all "Cute Pink" "󰏘"
            ;;
        *)
            echo "Unknown theme: $theme" >&2
            return 2
            ;;
    esac

    write_wofi_launcher_style "$theme"

    case "$theme" in
        "pastel-blue") set_wallpaper "$PASTEL_BLUE_WALLPAPER" ;;
        *)             set_wallpaper "$GRUVBOX_WALLPAPER" ;;
    esac
}

get_current_theme() {
    [[ -f "$THEME_FILE" ]] && cat "$THEME_FILE" || echo "purple"
}

case "${1:-menu}" in
    "purple")
        apply_theme "purple"
        ;;
    "pastel-blue"|"blue")
        apply_theme "pastel-blue"
        ;;
    "cute-pink"|"pink")
        apply_theme "cute-pink"
        ;;
    "toggle"|"next")
        curr=$(get_current_theme)
        case "$curr" in
            "purple") apply_theme "pastel-blue" ;;
            "pastel-blue") apply_theme "cute-pink" ;;
            *) apply_theme "purple" ;;
        esac
        ;;
    "menu"|*)
        options="󰏘 Purple Dark\n󰔏 Pastel Blue\n󰏘 Cute Pink"
        chosen=$(echo -e "$options" | wofi --dmenu --prompt "  Select Theme" --insensitive --width 250 --height 180)
        case "$chosen" in
            *"Purple"*)  apply_theme "purple" ;;
            *"Pastel Blue"*) apply_theme "pastel-blue" ;;
            *"Cute Pink"*) apply_theme "cute-pink" ;;
        esac
        ;;
esac
