"""Check the AUR package payload and publish only to temporary local remotes."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
RECIPE = ROOT / "aur/pixora-icons-git"
THEMES = ("pixora", "pixora-dark", "pixora-accent")


class PackageTests(unittest.TestCase):
    def test_package_contains_all_themes_and_preserves_artwork_and_aliases(self):
        tracked = subprocess.check_output(
            ["git", "ls-files", "-z", "--", *THEMES, "README.md"], cwd=ROOT,
        ).decode().split("\0")
        with tempfile.TemporaryDirectory(prefix="pixora-package-") as directory:
            work = Path(directory)
            source = work / "source/pixora-icons"
            payload = work / "package"
            for name in filter(None, tracked):
                original, target = ROOT / name, source / name
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(original, target, follow_symlinks=False)
            result = subprocess.run(
                ["bash", "-euo", "pipefail", "-c", 'source "$1"; package', "package-test", str(RECIPE / "PKGBUILD")],
                env={**os.environ, "srcdir": str(source.parent), "pkgdir": str(payload)},
                text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            icons = payload / "usr/share/icons"
            for theme in THEMES:
                self.assertTrue((icons / theme / "index.theme").is_file(), theme)
            for name in filter(None, tracked):
                if name == "README.md":
                    continue
                original, installed = ROOT / name, icons / name
                if original.is_symlink():
                    self.assertTrue(installed.is_symlink(), name)
                    self.assertEqual(os.readlink(installed), os.readlink(original), name)
                    self.assertTrue(installed.exists(), name)
                    self.assertTrue(installed.resolve().is_relative_to(icons.resolve()), name)
                else:
                    self.assertEqual(installed.read_bytes(), original.read_bytes(), name)
                    self.assertEqual(installed.stat().st_mode & 0o777, 0o644, name)
            for path in icons.rglob("*"):
                if path.is_dir() and not path.is_symlink():
                    self.assertEqual(path.stat().st_mode & 0o777, 0o755, path)
            self.assertEqual(
                (payload / "usr/share/doc/pixora-icons-git/README.md").read_bytes(),
                (ROOT / "README.md").read_bytes(),
            )


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="pixora-aur-")
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.remote = self.work / "aur remote.git"
        self.seed = self.work / "old AUR recipe"
        self.source = self.work / "GitHub recipe"
        self.source.mkdir()
        self.env = {
            **os.environ, "GIT_AUTHOR_NAME": "Package Test", "GIT_COMMITTER_NAME": "Package Test",
            "GIT_AUTHOR_EMAIL": "test@example.invalid", "GIT_COMMITTER_EMAIL": "test@example.invalid",
            "GIT_TERMINAL_PROMPT": "0",
        }
        self.git("init", "--bare", "--initial-branch=master", str(self.remote))
        self.git("clone", str(self.remote), str(self.seed))
        for name in ("PKGBUILD", ".SRCINFO"):
            (self.seed / name).write_text("old AUR recipe\n")
            shutil.copy2(RECIPE / name, self.source / name)
        (self.seed / "keep.txt").write_text("AUR-only file\n")
        self.git("-C", str(self.seed), "add", ".")
        self.git("-C", str(self.seed), "commit", "-m", "Existing AUR package")
        self.git("-C", str(self.seed), "push", "origin", "master")

    def git(self, *args):
        return subprocess.check_output(["git", *args], env=self.env, stderr=subprocess.DEVNULL).decode().strip()

    def publish(self, source=None):
        return subprocess.run(
            ["bash", str(ROOT / "scripts/publish-aur.sh"), str(source or self.source), str(self.remote)],
            cwd=self.work, env=self.env, text=True, capture_output=True,
        )

    def test_github_recipe_replaces_old_aur_copy_without_changing_source(self):
        before = {p.name: p.read_bytes() for p in self.source.iterdir()}
        original_head = self.git("--git-dir", str(self.remote), "rev-parse", "master")
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for name, content in before.items():
            remote_content = subprocess.check_output(["git", "--git-dir", str(self.remote), "show", f"master:{name}"])
            self.assertEqual(remote_content, content)
            self.assertEqual((self.source / name).read_bytes(), content)
        self.assertEqual(self.git("--git-dir", str(self.remote), "show", "master:keep.txt"), "AUR-only file")
        self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", "master^"), original_head)

    def test_repeated_publication_does_not_create_an_empty_commit(self):
        self.assertEqual(self.publish().returncode, 0)
        before = self.git("--git-dir", str(self.remote), "rev-parse", "master")
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("already matches", result.stdout)
        self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", "master"), before)

    def test_missing_metadata_does_not_change_aur(self):
        before = self.git("--git-dir", str(self.remote), "rev-parse", "master")
        (self.source / ".SRCINFO").unlink()
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", "master"), before)

    def test_rejected_push_is_reported_without_changing_source_or_remote(self):
        before = self.git("--git-dir", str(self.remote), "rev-parse", "master")
        source = {p.name: p.read_bytes() for p in self.source.iterdir()}
        hook = self.remote / "hooks/pre-receive"
        hook.write_text("#!/bin/sh\nexit 1\n")
        hook.chmod(0o755)
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", "master"), before)
        self.assertEqual({p.name: p.read_bytes() for p in self.source.iterdir()}, source)

    def test_each_git_commit_publishes_a_new_matching_version(self):
        checkout = self.work / "theme checkout"
        self.git("init", "--initial-branch=main", str(checkout))
        before = {p.name: p.read_bytes() for p in self.source.iterdir()}
        for revision in (1, 2):
            (checkout / "README.md").write_text(f"Theme revision {revision}\n")
            self.git("-C", str(checkout), "add", "README.md")
            self.git("-C", str(checkout), "commit", "-m", f"Theme change {revision}")
            output = self.work / f"prepared {revision}"
            result = subprocess.run(
                ["bash", str(ROOT / "scripts/prepare-aur.sh"), str(self.source), str(checkout), str(output)],
                env=self.env, text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            version = f"1.0.0.r{revision}.g" + self.git("-C", str(checkout), "rev-parse", "--short=7", "HEAD")
            self.assertIn(f"pkgver={version}\n", (output / "PKGBUILD").read_text())
            self.assertIn("pkgrel=1\n", (output / "PKGBUILD").read_text())
            result = self.publish(output)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            metadata = self.git("--git-dir", str(self.remote), "show", "master:.SRCINFO")
            self.assertIn(f"\tpkgver = {version}\n", metadata)
            self.assertIn("\tpkgrel = 1\n", metadata)
            published = self.git("--git-dir", str(self.remote), "rev-parse", "master")
            self.assertEqual(self.publish(output).returncode, 0)
            self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", "master"), published)
        self.assertEqual({p.name: p.read_bytes() for p in self.source.iterdir()}, before)

    def test_shallow_checkout_cannot_generate_an_incorrect_revision_count(self):
        checkout = self.work / "shallow checkout"
        self.git("clone", "--depth=1", self.remote.as_uri(), str(checkout))
        output = self.work / "incorrect package"
        result = subprocess.run(
            ["bash", str(ROOT / "scripts/prepare-aur.sh"), str(self.source), str(checkout), str(output)],
            env=self.env, text=True, capture_output=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Full Git history", result.stderr)
        self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
