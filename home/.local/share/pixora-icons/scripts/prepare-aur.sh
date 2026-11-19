#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 3 ]]; then
    printf 'Usage: %s PACKAGE_DIRECTORY SOURCE_CHECKOUT OUTPUT_DIRECTORY\n' "$0" >&2
    exit 1
fi
recipe_dir=$(cd -- "$1" && pwd -P)
source_repo=$(cd -- "$2" && pwd -P)
output_dir=$3
git -C "$source_repo" rev-parse --verify HEAD > /dev/null
if [[ "$(git -C "$source_repo" rev-parse --is-shallow-repository)" != false ]]; then
    printf 'Full Git history is required to calculate pkgver.\n' >&2
    exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
mkdir -- "$work_dir/source"
ln -s -- "$source_repo" "$work_dir/source/pixora-icons"

# Use the recipe's own pkgver() so AUR metadata matches a local Git build.
version=$(srcdir="$work_dir/source"; source "$recipe_dir/PKGBUILD"; pkgver)
if [[ ! "$version" =~ ^[[:alnum:]._+]+$ ]]; then
    printf 'Invalid generated package version: %s\n' "$version" >&2
    exit 1
fi
cp -- "$recipe_dir/PKGBUILD" "$recipe_dir/.SRCINFO" "$work_dir/"
sed -i -e "s/^pkgver=.*/pkgver=$version/" -e 's/^pkgrel=.*/pkgrel=1/' "$work_dir/PKGBUILD"
# The checked-in .SRCINFO is validated with makepkg first. Only these two
# fields change for a new Git revision; CI verifies the prepared metadata too.
sed -i -e "s/^\tpkgver = .*/\tpkgver = $version/" -e 's/^\tpkgrel = .*/\tpkgrel = 1/' "$work_dir/.SRCINFO"
mkdir -- "$output_dir"
cp -- "$work_dir/PKGBUILD" "$work_dir/.SRCINFO" "$output_dir/"
printf 'Prepared pixora-icons-git %s-1\n' "$version"
