# Releasing flex_switch

Release changes go through a reviewed pull request to `main`. Keep the version and
the first changelog section in agreement, describe the net change from the latest
published version, and wait for every CI job to pass before merging.

CI checks Flutter 3.47.7 / Dart 3.13.5 and current stable Flutter, lower dependency
bounds, formatting, analysis, package tests, Pana's full score, and a warning-fatal
publish dry run. The showcase also runs on native macOS and Chrome with Wasm.
The example must also build an Android debug APK with Java 17 and an unsigned
iOS simulator app, and a Windows release. Windows CI also checks UTF-16 argument
conversion against malformed and valid input.

## Prepare the reviewed merge

Capture the full base commit SHA before merging the release pull request and the
full merged commit SHA from GitHub. Fetch `main` and tags, then use a clean checkout
at the merged commit. Re-run the package release checks on that commit:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
dart pub publish --dry-run
dart pub global activate pana 0.23.19
pana --exit-code-threshold 0 .
```

Run the guard with those two verified SHAs and a notes file outside the checkout:

```sh
python3 .github/scripts/release_metadata.py prepare \
  --before <full-release-PR-base-SHA> \
  --expected-sha <full-merged-SHA> \
  --notes-path /tmp/flex-switch-release-notes.md
```

The guard checks the package identity, stable version, monotonic version increase,
current changelog section, clean checkout, exact commit, and absence of the release
tag locally and on `origin`. It prints the version, tag, and commit; it does not
create or push a tag.

## Publish from the immutable tag

Use the tag printed by the guard and the same merged SHA:

```sh
git tag <printed-tag> <full-merged-SHA>
git push origin refs/tags/<printed-tag>
gh release create <printed-tag> --verify-tag --target <full-merged-SHA> \
  --notes-file /tmp/flex-switch-release-notes.md
```

Push with the release operator's existing authenticated GitHub identity. A tag
pushed with an Actions `GITHUB_TOKEN` does not start another workflow. This
repository does not require a new tag-push PAT or a separate `dev` branch.

`publish.yml` runs only for `flex_switch-v*` tag pushes. It validates the package,
version, and exact tag, then calls
`dart-lang/setup-dart/.github/workflows/publish.yml@v1` with `id-token: write`.
Configure pub.dev's GitHub Actions publisher for `omar-hanafy/flex_switch` with tag
pattern `flex_switch-v{{version}}` and no environment. Preserve the current manual
publishing setting unless a separate policy change is requested.

Match the publish run to both the tag and the merged SHA. A release is complete
only when that run succeeds and pub.dev exposes the exact version. Keep tags and
published versions immutable; recover from a failed tag with a reviewed fix and a
new version.

References: [Dart automated publishing](https://dart.dev/tools/pub/automated-publishing)
and [GitHub workflow triggering](https://docs.github.com/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).
