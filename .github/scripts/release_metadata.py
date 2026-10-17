#!/usr/bin/env python3
"""Validate release metadata before CI or a reviewed stable tag push."""

import argparse
from pathlib import Path
import re
import subprocess
import sys


PACKAGE = "flex_switch"
STABLE_VERSION = re.compile(
    r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
)
COMMIT_SHA = re.compile(r"[0-9a-f]{40}")


class ReleaseError(Exception):
    """A release invariant was not satisfied."""


def git(*args):
    result = subprocess.run(
        ["git", *args], capture_output=True, text=True, check=False
    )
    if result.returncode:
        raise ReleaseError(result.stderr.strip() or f"git {args[0]} failed.")
    return result.stdout.strip()


def manifest(text):
    values = {}
    for key in ("name", "version"):
        matches = re.findall(rf"^{key}:\s*(.*?)\s*$", text, flags=re.MULTILINE)
        if len(matches) != 1:
            raise ReleaseError(f"Expected one top-level {key} in pubspec.yaml.")
        value = matches[0].split(" #", 1)[0].strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        values[key] = value
    if values["name"] != PACKAGE:
        raise ReleaseError(f"Expected package {PACKAGE}, got {values['name']}.")
    match = STABLE_VERSION.fullmatch(values["version"])
    if not match:
        raise ReleaseError(f"Main requires a stable version, got {values['version']}.")
    return values["version"], tuple(int(part) for part in match.groups())


def release_notes(changelog, version):
    lines = changelog.splitlines()
    headings = [(index, line.strip()) for index, line in enumerate(lines)
                if line.startswith("## ")]
    pattern = re.compile(
        rf"## (?:\[{re.escape(version)}\]|{re.escape(version)})"
        r"(?: - [0-9]{4}-[0-9]{2}-[0-9]{2})?"
    )
    matches = [index for index, heading in headings if pattern.fullmatch(heading)]
    if len(matches) != 1:
        raise ReleaseError(f"Expected one changelog section for {version}.")
    if headings[0][0] != matches[0]:
        raise ReleaseError(f"The first changelog section must describe {version}.")
    start = matches[0] + 1
    end = next((index for index, _ in headings if index >= start), len(lines))
    notes = "\n".join(lines[start:end]).strip()
    if not any(line.strip().lstrip("-* ") for line in notes.splitlines()
               if not line.strip().startswith("#")):
        raise ReleaseError(f"Changelog section for {version} has no release notes.")
    return notes + "\n"


def validate(before=None, tag=None):
    version, precedence = manifest(Path("pubspec.yaml").read_text())
    notes = release_notes(Path("CHANGELOG.md").read_text(), version)
    changed = False
    if before and before != "0" * 40:
        if not COMMIT_SHA.fullmatch(before):
            raise ReleaseError("The baseline must be a full commit SHA.")
        old_version, old_precedence = manifest(git("show", f"{before}:pubspec.yaml"))
        changed = version != old_version
        if changed and precedence <= old_precedence:
            raise ReleaseError(f"Version {version} must be newer than {old_version}.")
    expected_tag = f"{PACKAGE}-v{version}"
    if tag is not None and tag != expected_tag:
        raise ReleaseError(f"Expected release tag {expected_tag}, got {tag}.")
    return version, notes, changed, expected_tag


def prepare(args):
    version, notes, changed, tag = validate(args.before)
    if not changed:
        raise ReleaseError("A release requires a version change from the reviewed baseline.")
    if not COMMIT_SHA.fullmatch(args.expected_sha):
        raise ReleaseError("The reviewed merge must be a full commit SHA.")
    if git("rev-parse", "HEAD") != args.expected_sha:
        raise ReleaseError("HEAD does not match the reviewed merged commit.")
    if git("status", "--porcelain"):
        raise ReleaseError("The release checkout must be clean before preparing a tag.")
    if git("tag", "--list", tag):
        raise ReleaseError(f"Tag {tag} already exists locally; release tags are immutable.")
    if git("ls-remote", "--tags", "origin", f"refs/tags/{tag}"):
        raise ReleaseError(f"Tag {tag} already exists remotely; release tags are immutable.")
    args.notes_path.write_text(notes)
    print(f"version={version}\ntag={tag}\ncommit={args.expected_sha}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    check = commands.add_parser("check", help="Check stable metadata and optional baseline/tag.")
    check.add_argument("--before")
    check.add_argument("--tag")
    release = commands.add_parser("prepare", help="Check a clean merged commit and write notes.")
    release.add_argument("--before", required=True)
    release.add_argument("--expected-sha", required=True)
    release.add_argument("--notes-path", required=True, type=Path)
    args = parser.parse_args()
    try:
        if args.command == "prepare":
            prepare(args)
        else:
            version, _, changed, tag = validate(args.before, args.tag)
            print(f"Validated {PACKAGE} {version}; tag {tag}; version changed: {changed}.")
    except (ReleaseError, OSError) as error:
        print(f"Release metadata error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
