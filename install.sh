#!/usr/bin/env bash
#
# Instalador de la configuracion de Void Linux + Umbriel.
# Ejecutar como usuario normal con sudo disponible.
#
set -euo pipefail

REPO=$(cd "$(dirname "$0")" && pwd)

say() { printf '\n==> %s\n' "$*"; }
warn() { printf 'aviso: %s\n' "$*" >&2; }

[ -f /etc/void-release ] || { echo "error: se requiere Void Linux" >&2; exit 1; }
[ "$(id -u)" -ne 0 ] || { echo "error: ejecutar como usuario, no como root" >&2; exit 1; }

sudo -v

say "Repositorios xbps"
sudo install -Dm644 "$REPO"/system/etc/xbps.d/*.conf /etc/xbps.d/
sudo xbps-install -S

say "Paquetes"
# Se instala el conjunto completo de paquetes del sistema original (723),
# no solo los explicitos, para no depender de dependencias resueltas distinto.
while IFS= read -r pkg; do
    [ -n "$pkg" ] || continue
    sudo xbps-install -y "$pkg" || warn "no se pudo instalar $pkg"
done < "$REPO/packages/installed-names.txt"

say "Archivos de /etc"
sudo cp -R "$REPO"/system/etc/. /etc/

say "Servicios runit"
while IFS= read -r svc; do
    [ -d "/etc/sv/$svc" ] || { warn "servicio $svc no existe"; continue; }
    sudo ln -sfn "/etc/sv/$svc" "/var/service/$svc"
done < "$REPO/system/services.txt"

say "Dotfiles del home"
cp -a "$REPO"/home/. "$HOME"/

say "Grupos y shell"
for grp in audio video network wheel users _seatd; do
    getent group "$grp" >/dev/null && sudo usermod -aG "$grp" "$USER"
done
if command -v fish >/dev/null && [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/fish ]; then
    sudo chsh -s /usr/bin/fish "$USER"
fi

say "Flatpaks (opcional)"
if command -v flatpak >/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    awk -F'\t' 'NF && $1 != "" { print $1 }' "$REPO/packages/flatpak.txt" | sort -u |
        while IFS= read -r app; do
            flatpak install -y flathub "$app" >/dev/null 2>&1 || warn "flatpak $app no instalado"
        done
fi

say "Caches de fuentes e iconos"
fc-cache -f >/dev/null
for theme in "$HOME"/.local/share/icons/*; do
    [ -f "$theme/index.theme" ] && gtk-update-icon-cache -f -t "$theme" >/dev/null 2>&1 || true
done
command -v update-desktop-database >/dev/null &&
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

cat <<'EOF'

Listo. Reiniciar para que Ly cargue la sesion de Umbriel.

Pendiente de instalacion manual (no incluido por tamano):
  Zed              https://zed.dev
  IntelliJ IDEA    https://www.jetbrains.com/idea/
  Discord          https://discord.com/download
  Spotifast        ~/.local/opt/spotifast.AppImage
  Zapfast          ~/.local/opt/zapfast.AppImage
EOF
