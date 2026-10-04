#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
    printf 'Ejecutá este script como usuario normal; usará sudo cuando haga falta.\n' >&2
    exit 1
fi

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".before-dotfiles"

sudo -v
while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

if ! command -v pacman >/dev/null 2>&1 || [[ ! -r /etc/arch-release ]]; then
    printf 'Este instalador requiere Arch Linux y pacman.\n' >&2
    exit 1
fi

read_packages() {
    local file=$1
    mapfile -t packages < <(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "$ROOT_DIR/$file")
}

install_package_list() {
    local file=$1
    read_packages "$file"
    ((${#packages[@]})) || return 0
    sudo pacman -S --needed "${packages[@]}"
}

install_package_list packages.txt

if ! command -v yay >/dev/null 2>&1; then
    build_dir="$(mktemp -d)"
    trap 'rm -rf "$build_dir"; kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
    (
        cd "$build_dir/yay-bin"
        makepkg -si --noconfirm
    )
    rm -rf "$build_dir"
    trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
fi

install_package_list aur-packages.txt

backup_file() {
    local destination=$1
    if [[ -e "$destination" && ! -e "${destination}${BACKUP_SUFFIX}" ]]; then
        cp -a -- "$destination" "${destination}${BACKUP_SUFFIX}"
    fi
}

copy_tree() {
    local source=$1
    local destination=$2
    local file relative target
    while IFS= read -r -d '' file; do
        relative="${file#"$source"/}"
        target="$destination/$relative"
        mkdir -p "$(dirname -- "$target")"
        backup_file "$target"
        cp -a -- "$file" "$target"
    done < <(find "$source" -type f -print0)
}

copy_tree "$ROOT_DIR/.config" "$HOME/.config"
copy_tree "$ROOT_DIR/.local" "$HOME/.local"
copy_tree "$ROOT_DIR/Pictures/wallpapers" "$HOME/Pictures/wallpapers"
mkdir -p "$HOME/Pictures"
backup_file "$HOME/Pictures/fetchimage.png"
cp -a "$ROOT_DIR/Pictures/fetchimage.png" "$HOME/Pictures/fetchimage.png"

sudo mkdir -p /etc/fonts /etc/tlp.d
if sudo test -e /etc/fonts/local.conf; then
    sudo test -e /etc/fonts/local.conf.before-dotfiles ||
        sudo cp -a /etc/fonts/local.conf /etc/fonts/local.conf.before-dotfiles
fi
sudo install -Dm644 "$ROOT_DIR/etc/fonts/local.conf" /etc/fonts/local.conf
sudo install -Dm644 "$ROOT_DIR/etc/tlp.d/01-custom.conf" /etc/tlp.d/01-custom.conf

chmod +x \
    "$HOME/.local/bin/"{bri,vol,menu,dur-screensaver-start,dur-screensaver-stop,dur-screensaver-player,screensaver} \
    "$HOME/.config/mango/"{screenshot,wallpaper,wallpaper_switcher} \
    "$HOME/.config/waybar/"{mango-state,powermenu}
fc-cache -f

if [[ -f "$HOME/.config/nvim/init.lua" || -d "$HOME/.config/nvim/lua" ]]; then
    printf 'Se conserva la configuración existente de Neovim.\n'
else
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
fi

if systemctl list-unit-files power-profiles-daemon.service >/dev/null 2>&1; then
    sudo systemctl disable --now power-profiles-daemon.service || true
    sudo systemctl mask power-profiles-daemon.service || true
fi
sudo systemctl enable --now tlp.service
sudo tlp start
systemctl --user daemon-reload
systemctl --user enable --now swayidle-screensaver.service

gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme Adwaita 2>/dev/null || true

printf '\nInstalación completa. Los archivos reemplazados conservan una copia con sufijo %s.\n' "$BACKUP_SUFFIX"
