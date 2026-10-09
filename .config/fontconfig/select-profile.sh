#!/bin/sh
set -eu

profile="${1:-equilibrado}"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig"
target="$config_dir/profiles/$profile.conf"

case "$profile" in
  macos-suave|equilibrado|nitido) ;;
  *) printf 'Perfil inválido: %s\n' "$profile" >&2; exit 2 ;;
esac

[ -f "$target" ] || { printf 'No existe: %s\n' "$target" >&2; exit 1; }
mkdir -p "$config_dir"
ln -sfn "profiles/$profile.conf" "$config_dir/fonts.conf"
fc-cache -f
printf 'Perfil activo: %s\n' "$profile"
