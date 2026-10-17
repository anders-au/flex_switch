"""Exercise release guards with disposable Git repositories and an empty origin."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("release_metadata.py").resolve()


class ReleaseMetadataTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        subprocess.run(["git", "init", "--bare", "-q", str(self.root / "origin")], check=True)
        self.git("init", "-q")
        self.git("config", "user.name", "Release fixture")
        self.git("config", "user.email", "release-fixture@example.invalid")
        self.git("remote", "add", "origin", str(self.root / "origin"))
        self.write_version("1.2.1")
        self.commit()
        self.baseline = self.git("rev-parse", "HEAD")
        self.write_version("2.0.0")
        self.commit()
        self.head = self.git("rev-parse", "HEAD")

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.repo, capture_output=True,
                              text=True, check=True).stdout.strip()

    def write_version(self, version):
        (self.repo / "pubspec.yaml").write_text(f"name: flex_switch\nversion: {version}\n")
        (self.repo / "CHANGELOG.md").write_text(
            f"# Changelog\n\n## [{version}] - 2026-10-11\n\n"
            "### Changed\n\n- Require the current supported SDK.\n\n"
            "## [1.0.0] - 2025-09-15\n\nInitial release.\n"
        )

    def commit(self):
        self.git("add", "pubspec.yaml", "CHANGELOG.md")
        self.git("commit", "-qm", "update fixture")

    def run_guard(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], cwd=self.repo,
                              capture_output=True, text=True, check=False)

    def prepare(self, **overrides):
        options = {"before": self.baseline, "expected-sha": self.head,
                   "notes-path": str(self.root / "release-notes.md")}
        options.update(overrides)
        args = ["prepare"]
        for key, value in options.items():
            args.extend([f"--{key}", value])
        return self.run_guard(*args)

    def test_prepare_writes_only_curated_current_notes(self):
        result = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"tag=flex_switch-v2.0.0\ncommit={self.head}", result.stdout)
        self.assertEqual((self.root / "release-notes.md").read_text(),
                         "### Changed\n\n- Require the current supported SDK.\n")

    def test_metadata_edit_does_not_create_a_release(self):
        self.assertEqual(self.run_guard("check", "--before", self.head).returncode, 0)
        result = self.prepare(before=self.head)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires a version change", result.stderr)

    def test_downgrade_is_rejected(self):
        self.write_version("1.2.0")
        result = self.run_guard("check", "--before", self.baseline)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("must be newer", result.stderr)

    def test_prerelease_is_rejected_on_main(self):
        self.write_version("2.0.0-beta.1")
        result = self.run_guard("check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires a stable version", result.stderr)

    def test_tag_must_match_manifest_exactly(self):
        result = self.run_guard("check", "--tag", "flex_switch-v1.2.1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected release tag flex_switch-v2.0.0", result.stderr)

    def test_package_name_must_match(self):
        (self.repo / "pubspec.yaml").write_text("name: other_package\nversion: 2.0.0\n")
        result = self.run_guard("check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected package flex_switch", result.stderr)

    def test_notes_cannot_be_empty(self):
        (self.repo / "CHANGELOG.md").write_text("# Changelog\n\n## [2.0.0]\n\n### Changed\n")
        result = self.run_guard("check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("has no release notes", result.stderr)

    def test_duplicate_version_headings_are_rejected(self):
        with (self.repo / "CHANGELOG.md").open("a") as changelog:
            changelog.write("\n## 2.0.0\n\nRepeated notes.\n")
        result = self.run_guard("check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected one changelog section", result.stderr)

    def test_dirty_release_checkout_is_rejected(self):
        (self.repo / "unreviewed.txt").write_text("unreviewed")
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("must be clean", result.stderr)

    def test_different_merge_commit_is_rejected(self):
        result = self.prepare(**{"expected-sha": self.baseline})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("does not match", result.stderr)

    def test_existing_local_tag_is_rejected(self):
        self.git("tag", "flex_switch-v2.0.0")
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("already exists locally", result.stderr)

    def test_existing_remote_tag_is_rejected(self):
        self.git("tag", "flex_switch-v2.0.0")
        self.git("push", "-q", "origin", "refs/tags/flex_switch-v2.0.0")
        self.git("tag", "-d", "flex_switch-v2.0.0")
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("already exists remotely", result.stderr)


if __name__ == "__main__":
    unittest.main()
