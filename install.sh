#!/usr/bin/env bash
# Instalador de dotfiles para Arch Linux.
# Ejecutar como usuario normal; usa `sudo` cuando hace falta.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
    printf 'Ejecutá este script como usuario normal; usará sudo cuando haga falta.\n' >&2
    exit 1
fi

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".before-dotfiles"

if ! command -v pacman >/dev/null 2>&1 || [[ ! -r /etc/arch-release ]]; then
    printf 'Este instalador requiere Arch Linux y pacman. En Fedora usá ./install-fedora.sh\n' >&2
    exit 1
fi

# Mantener el ticket de sudo vivo durante todo el script.
sudo -v
while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

# Helper para el listado de paquetes: ignora líneas vacías y comentarios.
read_packages() {
    local file=$1
    mapfile -t packages < <(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "$ROOT_DIR/$file")
}

install_package_list() {
    local file=$1
    local pkg available
    read_packages "$file"
    ((${#packages[@]})) || return 0

    if [[ "$file" == aur-packages.txt ]]; then
        available=()
        for pkg in "${packages[@]}"; do
            if yay -Si "$pkg" >/dev/null 2>&1; then
                available+=("$pkg")
            else
                printf 'Aviso: paquete AUR no disponible, se omite: %s\n' "$pkg" >&2
            fi
        done
        ((${#available[@]})) && yay -S --needed "${available[@]}"
    else
        sudo pacman -S --needed "${packages[@]}"
    fi
}

install_package_list packages.txt

# Si no está yay, lo compilamos desde el AUR (yay-bin).
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

# Copia los archivos, conservando un backup con BACKUP_SUFFIX la primera vez.
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
    if [[ ! -d "$source" ]]; then
        return 0
    fi
    while IFS= read -r -d '' file; do
        relative="${file#"$source"/}"
        target="$destination/$relative"
        mkdir -p "$(dirname -- "$target")"
        backup_file "$target"
        cp -a -- "$file" "$target"
    done < <(find "$source" -type f -print0)
}

install_file() {
    local source=$1
    local target=$2
    mkdir -p "$(dirname -- "$target")"
    backup_file "$target"
    cp -a -- "$source" "$target"
}

copy_tree "$ROOT_DIR/.config" "$HOME/.config"
copy_tree "$ROOT_DIR/.local" "$HOME/.local"
copy_tree "$ROOT_DIR/Pictures/wallpapers" "$HOME/Pictures/wallpapers"
install_file "$ROOT_DIR/Pictures/fetchimage.png" "$HOME/Pictures/fetchimage.png"

sudo mkdir -p /etc/fonts /etc/tlp.d /etc/ly
if sudo test -e /etc/fonts/local.conf && ! sudo test -e /etc/fonts/local.conf.before-dotfiles; then
    sudo cp -a /etc/fonts/local.conf /etc/fonts/local.conf.before-dotfiles
fi
sudo install -Dm644 "$ROOT_DIR/etc/fonts/local.conf" /etc/fonts/local.conf
sudo install -Dm644 "$ROOT_DIR/etc/tlp.d/01-custom.conf" /etc/tlp.d/01-custom.conf
if sudo test -e /etc/ly/config.ini && ! sudo test -e /etc/ly/config.ini.before-dotfiles; then
    sudo cp -a /etc/ly/config.ini /etc/ly/config.ini.before-dotfiles
fi
sudo install -Dm644 "$ROOT_DIR/etc/ly/config.ini" /etc/ly/config.ini
# Animación DurMovie que usa Ly y el screensaver (~/.local/bin/dur-screensaver-player).
sudo install -Dm644 "$ROOT_DIR/etc/ly/blackhole-smooth-240x67.dur" /etc/ly/blackhole-smooth-240x67.dur

chmod +x \
    "$HOME/.local/bin/"{apply-wallpaper,bri,vol,menu,dur-screensaver-start,dur-screensaver-stop,dur-screensaver-player,screensaver} \
    "$HOME/.config/mango/"{screenshot,wallpaper,wallpaper_switcher} \
    "$HOME/.config/rofi/rofi-drun.sh" \
    "$HOME/.config/waybar/"{mango-state,powermenu} \
    "$HOME/.config/matugen/reload.sh"
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
sudo systemctl enable --now bluetooth.service
sudo systemctl enable ly@tty1.service
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
systemctl --user enable swayidle-screensaver.service 2>/dev/null || true

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme Adwaita 2>/dev/null || true
fi

printf '\nInstalación completa. Los archivos reemplazados conservan una copia con sufijo %s.\n' "$BACKUP_SUFFIX"
printf 'Reiniciá para entrar con Ly, o iniciá mango con `mango` desde una TTY.\n'