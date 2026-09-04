#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

link_path() {
    local source="$1"
    local target="$2"

    mkdir -p "$(dirname -- "$target")"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$(readlink -f -- "$target" 2>/dev/null || true)" == "$source" ]]; then
            return
        fi
        mv -- "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
    fi
    ln -s -- "$source" "$target"
}

for entry in \
    btop cava fastfetch fuzzel gtk-3.0 gtk-4.0 kitty mako ncspot niri \
    nvim quickshell spotify-tui theme-palette waybar wofi yazi scripts
do
    link_path "$DOTFILES_DIR/$entry" "$HOME/.config/$entry"
done

for entry in .gitconfig .p10k.zsh .zshrc; do
    link_path "$DOTFILES_DIR/$entry" "$HOME/$entry"
done

echo "Dotfiles linked from $DOTFILES_DIR"
echo "Apply NixOS declarative changes with:"
echo "  sudo nixos-rebuild switch --flake $DOTFILES_DIR#nixos"
