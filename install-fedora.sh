#!/usr/bin/env bash
# Instalador de dotfiles para Fedora (netinstall "Everything").
# Ejecutar como usuario normal; usa `sudo` cuando hace falta.
#
# Hace lo mismo que install.sh pero con dnf y los nombres de paquete de Fedora:
#   - instala paquetes oficiales + RPM Fusion + Terra (mangowm y más) + Flathub
#   - baja JetBrainsMono Nerd Font (no está empaquetada en Fedora)
#   - compila algunas herramientas que no están ni en Fedora ni en Terra
#   - copia configs, scripts, wallpapers, fuentes, TLP y Ly
#   - habilita servicios (TLP, Bluetooth, PipeWire, Ly, screensaver)
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
    printf 'Ejecutá este script como usuario normal; usará sudo cuando haga falta.\n' >&2
    exit 1
fi

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".before-dotfiles"

if ! command -v dnf >/dev/null 2>&1 || [[ ! -r /etc/fedora-release ]]; then
    printf 'Este instalador requiere Fedora y dnf. En Arch usá ./install.sh\n' >&2
    exit 1
fi
FEDORA_RELEASE="$(rpm -E %fedora)"

# Mantener el ticket de sudo vivo durante todo el script.
sudo -v
while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

info() { printf '\n>>> %s\n' "$*"; }
warn() { printf 'Aviso: %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Repositorios
# ---------------------------------------------------------------------------
info 'Activando RPM Fusion (free + nonfree)'
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_RELEASE}.noarch.rpm"
fi
if ! rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
    sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_RELEASE}.noarch.rpm"
fi

info 'Activando flathub'
if ! command -v flatpak >/dev/null 2>&1; then
    sudo dnf install -y flatpak
fi
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# ---------------------------------------------------------------------------
# Paquetes oficiales de Fedora (verificados contra el repo Everything).
# ---------------------------------------------------------------------------
info 'Instalando paquetes oficiales (esto puede tardar)'
sudo dnf install -y \
    alsa-utils \
    alsa-sof-firmware \
    bluez \
    bluez-tools \
    brightnessctl \
    btop \
    btrfs-progs \
    cava \
    cmatrix \
    fastfetch \
    foot \
    chafa \
    fd-find \
    fish \
    fwupd \
    gh \
    grim \
    gvfs \
    kitty \
    mako \
    matugen \
    nano \
    neovim \
    NetworkManager \
    pamixer \
    papirus-icon-theme \
    pipewire-alsa \
    pipewire-pulseaudio \
    playerctl \
    powertop \
    rofi \
    swaybg \
    swayidle \
    thunar-volman \
    Thunar \
    tlp \
    tlp-rdw \
    tmux \
    tumbler \
    waybar \
    wf-recorder \
    wl-clipboard \
    wob \
    xdg-desktop-portal-wlr \
    slurp \
    vulkan-loader \
    mesa-vulkan-drivers \
    mesa-dri-drivers \
    microcode_ctl \
    libnotify \
    polkit \
    xfce-polkit \
    xorg-x11-server-Xwayland \
    seatd \
    git \
    curl \
    tar \
    unzip \
    make \
    gcc \
    gcc-c++ \
    ncurses-devel \
    cargo \
    pipx \
    python3 \
    fontconfig

info 'Instalando fuentes'
sudo dnf install -y \
    dejavu-sans-fonts \
    dejavu-serif-fonts \
    jetbrains-mono-fonts \
    google-noto-sans-fonts \
    google-noto-serif-fonts \
    google-noto-color-emoji-fonts \
    liberation-fonts-all

# JetBrainsMono Nerd Font no está empaquetada en Fedora; se baja de GitHub.
if ! fc-list 2>/dev/null | grep -qi 'nerd font'; then
    info 'Descargando JetBrainsMono Nerd Font'
    tmp_zip="$(mktemp --suffix=.zip)"
    curl -fL --max-time 300 -o "$tmp_zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    fonts_dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    mkdir -p "$fonts_dir"
    unzip -o -q "$tmp_zip" -d "$fonts_dir"
    rm -f "$tmp_zip"
fi

# ---------------------------------------------------------------------------
# Paquetes de Terra (mangowm es el compositor y no está en Fedora).
# https://docs.fyralabs.com/terra-install
# ---------------------------------------------------------------------------
info 'Activando el repositorio Terra'
if ! rpm -q terra-release >/dev/null 2>&1; then
    sudo dnf install --nogpgcheck \
        --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
        terra-release
fi
info 'Instalando paquetes de Terra (mangowm, satty, starship, yazi, ...)'
sudo dnf install -y \
    mangowm \
    satty \
    starship \
    yazi \
    nwg-look \
    legcord \
    zed \
    opencode

# ---------------------------------------------------------------------------
# Herramientas que no están en Fedora ni en Terra.
# ---------------------------------------------------------------------------
# lazygit (Go, binario estático de GitHub)
if ! command -v lazygit >/dev/null 2>&1; then
    info 'Instalando lazygit'
    ver="$(curl -fsL --max-time 30 https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep -oP '"tag_name": "\K[^"]+')"
    if [[ -n "${ver:-}" ]]; then
        curl -fsL --max-time 120 -o /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/download/${ver}/lazygit_${ver#v}_Linux_x86_64.tar.gz"
        sudo tar -C /usr/local/bin -xzf /tmp/lazygit.tar.gz lazygit
        rm -f /tmp/lazygit.tar.gz
    else
        warn 'lazygit: no se pudo resolver la última release'
    fi
fi

# bluetui y wl-clip-persist (Rust, sin paquetes rpm)
if ! command -v bluetui >/dev/null 2>&1 || ! command -v wl-clip-persist >/dev/null 2>&1; then
    info 'Compilando bluetui y wl-clip-persist con cargo'
    sudo cargo install --locked --root /usr/local bluetui wl-clip-persist || warn 'cargo: fallaron bluetui/wl-clip-persist'
fi

# tty-clock (C, se compila del upstream)
if ! command -v tty-clock >/dev/null 2>&1; then
    info 'Compilando tty-clock'
    build_dir="$(mktemp -d)"
    if git clone --depth=1 https://github.com/xorg62/tty-clock.git "$build_dir/tty-clock"; then
        (
            cd "$build_dir/tty-clock"
            make
            sudo make install
        ) || warn 'tty-clock: la compilación falló'
    else
        warn 'tty-clock: no se pudo clonar el upstream'
    fi
    rm -rf "$build_dir"
fi

# durdraw (Python)
if ! command -v durdraw >/dev/null 2>&1; then
    info 'Instalando durdraw (pipx)'
    pipx install durdraw || warn 'durdraw: no se pudo instalar con pipx'
fi

# GitHub Copilot CLI vía extensión de gh
if command -v gh >/dev/null 2>&1 && ! gh extension list >/dev/null 2>&1 | grep -q gh-copilot; then
    info 'Instalando gh-copilot'
    gh extension install github/gh-copilot || warn 'gh-copilot: no se pudo instalar'
fi

# Aplicaciones de escritorio por flatpak (no empaquetadas en Fedora).
info 'Instalando apps de Flatpak (Obsidian, IntelliJ) — omití si no las querés'
flatpak install --user -y --noninteractive flathub md.obsidian.Obsidian  || warn 'flatpak: Obsidian falló'
flatpak install --user -y --noninteractive flathub com.jetbrains.IntelliJ-IDEA-Community || warn 'flatpak: IntelliJ falló'

# ---------------------------------------------------------------------------
# Display manager (Ly). Está en rawhide; si no está en tu Fedora se compila,
# y si eso falla se cae a greetd+tuigreet.
# ---------------------------------------------------------------------------
install_display_manager() {
    if sudo dnf install -y ly >/dev/null 2>&1; then
        return 0
    fi
    warn 'ly no está empaquetado en esta versión de Fedora; intento compilarlo'
    build_dir="$(mktemp -d)"
    if git clone --depth=1 --branch v1.4.1 https://codeberg.org/fairyglade/ly "$build_dir/ly" 2>/dev/null &&
        (cd "$build_dir/ly" && zig build -Doptimize=ReleaseSafe --prefix "$build_dir/prefix"); then
        sudo install -Dm755 "$build_dir/prefix/bin/ly" /usr/local/bin/ly
        sudo install -Dm644 "$build_dir/prefix/etc/ly/config.ini" /etc/ly/config.ini.example 2>/dev/null || true
        rm -rf "$build_dir"
        return 0
    fi
    rm -rf "$build_dir"
    warn 'no se pudo compilar ly; usando greetd+tuigreet como display manager'
    sudo dnf install -y greetd tuigreet
    # Autologin a mango (sin greeter, como un admin de un solo usuario).
    sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[initial_session]
command = "mango"
user = "$(id -un)"

[default_session]
command = "tuigreet --time --cmd mango"
user = "$(id -un)"
EOF
    sudo systemctl enable greetd
    return 1
}

info 'Instalando display manager'
if install_display_manager; then
    DM=ly
else
    DM=greetd
fi

# ---------------------------------------------------------------------------
# Copiar configuraciones (mismos dotfiles que en Arch).
# ---------------------------------------------------------------------------
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

info 'Copiando configuraciones, scripts y wallpapers'
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
if [[ -f "$ROOT_DIR/etc/ly/config.ini" ]]; then
    if sudo test -e /etc/ly/config.ini && ! sudo test -e /etc/ly/config.ini.before-dotfiles; then
        sudo cp -a /etc/ly/config.ini /etc/ly/config.ini.before-dotfiles
    fi
    sudo install -Dm644 "$ROOT_DIR/etc/ly/config.ini" /etc/ly/config.ini
fi
# Animación DurMovie que usa Ly y el screensaver.
sudo install -Dm644 "$ROOT_DIR/etc/ly/blackhole-smooth-240x67.dur" /etc/ly/blackhole-smooth-240x67.dur

chmod +x \
    "$HOME/.local/bin/"{apply-wallpaper,bri,vol,menu,dur-screensaver-start,dur-screensaver-stop,dur-screensaver-player,screensaver} \
    "$HOME/.config/mango/"{screenshot,wallpaper,wallpaper_switcher} \
    "$HOME/.config/rofi/rofi-drun.sh" \
    "$HOME/.config/waybar/"{mango-state,powermenu} \
    "$HOME/.config/matugen/reload.sh"
fc-cache -f

# Fedora empaqueta fd como fdfind; algunos programas esperan el comando `fd`.
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# wob no siempre trae su unidad de socket de usuario en Fedora; si falta, se crea.
if [[ ! -e /usr/lib/systemd/user/wob.socket && ! -e "$HOME/.config/systemd/user/wob.socket" ]]; then
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/wob.socket" <<'EOF'
[Socket]
ListenFIFO=%t/wob.sock
SocketMode=0600
RemoveOnStop=on
FlushPending=yes

[Install]
WantedBy=sockets.target
EOF
fi

if [[ -f "$HOME/.config/nvim/init.lua" || -d "$HOME/.config/nvim/lua" ]]; then
    printf 'Se conserva la configuración existente de Neovim.\n'
else
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
fi

# ---------------------------------------------------------------------------
# Servicios
# ---------------------------------------------------------------------------
if systemctl list-unit-files power-profiles-daemon.service >/dev/null 2>&1; then
    sudo systemctl disable --now power-profiles-daemon.service 2>/dev/null || true
    sudo systemctl mask power-profiles-daemon.service 2>/dev/null || true
fi
sudo systemctl enable --now tlp.service 2>/dev/null || warn 'tlp.service no disponible'
sudo systemctl enable --now bluetooth.service 2>/dev/null || warn 'bluetooth.service no disponible'

case "$DM" in
    ly)
        if systemctl list-unit-files 'ly@.service' >/dev/null 2>&1; then
            sudo systemctl enable ly@tty1.service
        elif systemctl list-unit-files ly.service >/dev/null 2>&1; then
            sudo systemctl enable ly.service
        else
            # Unidad propia para un ly compilado en /usr/local/bin.
            ly_bin="$(command -v ly-dm || command -v ly || echo /usr/local/bin/ly)"
            sudo tee /etc/systemd/system/ly@.service >/dev/null <<EOF
[Unit]
Description=TUI display manager
After=systemd-user-sessions.service plymouth-quit-wait.service
After=getty@%i.service
Conflicts=getty@%i.service

[Service]
Type=idle
ExecStart=${ly_bin}
StandardInput=tty
TTYPath=/dev/%I
TTYReset=yes
TTYVHangup=yes

[Install]
WantedBy=multi-user.target
EOF
            sudo systemctl daemon-reload
            sudo systemctl enable ly@tty1.service
        fi
        ;;
    greetd)
        sudo systemctl enable greetd
        ;;
esac

systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true
systemctl --user enable swayidle-screensaver.service 2>/dev/null || true

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme Adwaita 2>/dev/null || true
fi

printf '\nInstalación completa. Los archivos reemplazados conservan una copia con sufijo %s.\n' "$BACKUP_SUFFIX"
printf 'Reiniciá para entrar con el display manager. Si usaste greetd, ya inicia mango.\n'
printf 'Aviso: si el menú de energía no pide contraseña, iniciá "xfce-polkit" desde mango\n'
printf '       (agregá "exec-once=xfce-polkit" a ~/.config/mango/config.conf).\n'