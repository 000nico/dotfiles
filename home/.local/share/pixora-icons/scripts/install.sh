#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
icon_root="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
themes=(pixora pixora-dark pixora-accent)

for theme in "${themes[@]}"; do
    if [[ ! -f "$repo_root/$theme/index.theme" ]]; then
        printf 'Missing theme: %s\n' "$repo_root/$theme" >&2
        exit 1
    fi
    # A real source directory must never be removed as an install destination.
    # An existing installation symlink can safely be replaced.
    if [[ ! -L "$icon_root/$theme" && "$icon_root/$theme" -ef "$repo_root/$theme" ]]; then
        printf 'The installation directory contains the source theme: %s\n' "$icon_root/$theme" >&2
        exit 1
    fi
done

printf '\nPixora Icon Theme — Installer\n'
printf 'Variants: Pixora, Pixora Dark and Pixora Accent (KDE).\n'
printf 'Destination: %s\n\n' "$icon_root"

installed=false
for theme in "${themes[@]}"; do
    if [[ -e "$icon_root/$theme" || -L "$icon_root/$theme" ]]; then
        installed=true
    fi
done
if $installed; then
    read -r -p 'Replace the existing Pixora installations? [Y/n] ' confirm
    if [[ -n "$confirm" && "${confirm,,}" != "y" ]]; then
        printf 'Installation cancelled.\n'
        exit 0
    fi
fi

printf '1: Symbolic links — update this checkout with git pull.\n'
printf '2: Local copy — install without depending on this checkout.\n'
read -r -p 'Choose [1/2], or any other key to cancel: ' choice
case "$choice" in
    1)
        printf '\nKeep this directory in place: %s\n' "$repo_root"
        ;;
    2)
        printf '\nRe-run this installer after updating the source to refresh local copies.\n'
        ;;
    *)
        printf 'Installation cancelled.\n'
        exit 1
        ;;
esac
read -r -p 'Press Enter to continue...' _

mkdir -p -- "$icon_root"
stage_root=$(mktemp -d "$icon_root/.pixora-install.XXXXXX")
trap 'rm -rf -- "$stage_root"' EXIT

# Prepare every variant before replacing an existing installation. Archive
# copies preserve the relative links between Pixora Dark, Pixora and aliases.
for theme in "${themes[@]}"; do
    if [[ "$choice" == "1" ]]; then
        ln -s -- "$repo_root/$theme" "$stage_root/$theme"
    else
        cp -a -- "$repo_root/$theme" "$stage_root/$theme"
    fi
done
for theme in "${themes[@]}"; do
    rm -rf -- "$icon_root/$theme"
    mv -- "$stage_root/$theme" "$icon_root/$theme"
done

printf '\nInstalled all three variants in %s\n' "$icon_root"
printf 'For accent-colored folders, select Pixora Accent in KDE System Settings → Colors & Themes → Icons.\n'
printf 'Then choose an accent color in Colors.\n'
