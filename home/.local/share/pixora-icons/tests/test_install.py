"""Exercise installation, relocation and replacement without touching user icons."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
THEMES = ("pixora", "pixora-dark", "pixora-accent")


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="pixora-install-")
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.repo = self.work / "source checkout"
        (self.repo / "scripts").mkdir(parents=True)
        shutil.copy2(ROOT / "scripts/install.sh", self.repo / "scripts/install.sh")
        for name in THEMES:
            theme = self.repo / name
            theme.mkdir()
            (theme / "index.theme").write_text(f"[Icon Theme]\nName={name}\n")
        for name in ("pixora", "pixora-accent"):
            places = self.repo / name / "scalable/places"
            places.mkdir(parents=True)
            (places / "folder.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg"/>\n')
            (places / "inode-directory.svg").symlink_to("folder.svg")
        (self.repo / "pixora-dark/scalable").symlink_to("../pixora/scalable")
        self.data = self.work / "user data"
        self.icons = self.data / "icons"
        self.env = os.environ.copy()
        self.env["XDG_DATA_HOME"] = str(self.data)

    def run_installer(self, answers):
        return subprocess.run(
            ["bash", str(self.repo / "scripts/install.sh")],
            input=answers, text=True, capture_output=True,
            cwd=self.work, env=self.env,
        )

    def assert_complete(self, links):
        for name in THEMES:
            target = self.icons / name
            self.assertEqual(target.is_symlink(), links)
            self.assertEqual((target / "index.theme").read_bytes(), (self.repo / name / "index.theme").read_bytes())
            if links:
                self.assertEqual(target.resolve(), (self.repo / name).resolve())
            self.assertFalse((target / name).exists(), "reinstall nested the theme")
        self.assertEqual((self.icons / "pixora-dark/scalable").resolve(), (self.icons / "pixora/scalable").resolve())
        self.assertEqual(os.readlink(self.icons / "pixora-accent/scalable/places/inode-directory.svg"), "folder.svg")
        self.assertEqual(list(self.icons.glob(".pixora-install.*")), [])

    def test_links_from_unrelated_directory_and_paths_with_spaces(self):
        result = self.run_installer("1\n\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_complete(links=True)

    def test_copies_survive_source_removal(self):
        result = self.run_installer("2\n\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_complete(links=False)
        shutil.rmtree(self.repo)
        for name in THEMES:
            self.assertTrue((self.icons / name / "index.theme").is_file())
            self.assertTrue((self.icons / name / "scalable/places/inode-directory.svg").is_file())

    def test_reinstall_between_both_modes(self):
        for answers, links in [("1\n\n", True), ("Y\n2\n\n", False), ("\n1\n\n", True)]:
            result = self.run_installer(answers)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assert_complete(links)

    def test_cancel_after_reinstall_confirmation_keeps_existing_themes(self):
        self.assertEqual(self.run_installer("2\n\n").returncode, 0)
        marker = self.icons / "pixora-accent/local-marker"
        marker.write_text("keep this\n")
        self.assertEqual(self.run_installer("y\ncancel\n").returncode, 1)
        self.assertEqual(marker.read_text(), "keep this\n")
        self.assert_complete(links=False)

    def test_accent_only_installation_is_detected(self):
        accent = self.icons / "pixora-accent"
        accent.mkdir(parents=True)
        marker = accent / "local-marker"
        marker.write_text("keep this\n")
        self.assertEqual(self.run_installer("n\n").returncode, 0)
        self.assertEqual(marker.read_text(), "keep this\n")
        self.assertFalse((self.icons / "pixora").exists())

    def test_copy_failure_keeps_existing_installation(self):
        self.assertEqual(self.run_installer("2\n\n").returncode, 0)
        marker = self.icons / "pixora-accent/local-marker"
        marker.write_text("keep this\n")
        tools = self.work / "tools"
        tools.mkdir()
        failing_copy = tools / "cp"
        failing_copy.write_text("#!/bin/sh\nexit 73\n")
        failing_copy.chmod(0o755)
        self.env["PATH"] = str(tools) + os.pathsep + self.env["PATH"]
        self.assertEqual(self.run_installer("y\n2\n\n").returncode, 73)
        self.assertEqual(marker.read_text(), "keep this\n")
        self.assert_complete(links=False)

    def test_source_cannot_be_its_own_destination(self):
        self.data.mkdir()
        shutil.move(self.repo, self.icons)
        self.repo = self.icons
        result = self.run_installer("")
        self.assertEqual(result.returncode, 1)
        self.assertIn("contains the source theme", result.stderr)
        for name in THEMES:
            self.assertTrue((self.repo / name / "index.theme").is_file())

    def test_eof_does_not_create_installation(self):
        self.assertEqual(self.run_installer("").returncode, 1)
        self.assertFalse(self.icons.exists())


if __name__ == "__main__":
    unittest.main()
