# AUR packaging

Every push to `main` validates and publishes a new AUR version with Pixora, Pixora Dark and Pixora Accent. GitHub's packaging files are the source, and versions are calculated automatically.

To change the package:

1. Edit `aur/pixora-icons-git/PKGBUILD`;
2. On Arch Linux, run `makepkg --printsrcinfo > .SRCINFO` from that directory;
3. Run `python3 -m unittest discover -s tests` from the repository root and submit both packaging files together.

Publication requires the `AUR_KEY` secret in the `aur-packages` environment.

Users update through an AUR helper; `pacman -Syu` alone does not check AUR updates.
