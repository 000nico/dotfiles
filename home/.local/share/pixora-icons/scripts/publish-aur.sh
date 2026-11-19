#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 2 ]]; then
    printf 'Usage: %s PACKAGE_DIRECTORY AUR_REMOTE\n' "$0" >&2
    exit 1
fi
recipe_dir=$(cd -- "$1" && pwd -P)
aur_remote=$2
for file in PKGBUILD .SRCINFO; do
    if [[ ! -f "$recipe_dir/$file" || -L "$recipe_dir/$file" ]]; then
        printf 'Missing or symlinked packaging file: %s\n' "$recipe_dir/$file" >&2
        exit 1
    fi
done

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT

# AUR supplies its Git history; GitHub supplies the packaging files. Never
# import an AUR recipe into the source checkout or force-push AUR history.
git clone --quiet --single-branch --branch master -- "$aur_remote" "$work_dir/aur"
cp -- "$recipe_dir/PKGBUILD" "$recipe_dir/.SRCINFO" "$work_dir/aur/"
git -C "$work_dir/aur" add -- PKGBUILD .SRCINFO
if git -C "$work_dir/aur" diff --cached --quiet; then
    printf 'AUR already matches the GitHub packaging files.\n'
    exit 0
fi
git -C "$work_dir/aur" diff --cached --check
git -C "$work_dir/aur" commit -m 'Update pixora-icons-git packaging from GitHub'
git -C "$work_dir/aur" push origin HEAD:master
