---
name: release-check
description: Pre-release checklist for publishing viva_network_kit to pub.dev. Use when preparing, reviewing, or publishing a release (e.g. "check release 2.3.0", "ready to publish?", "bump version").
---

# Release check for viva_network_kit

Run every step with the FVM-pinned SDK from `.fvmrc`. Stop and report on the
first failure; do not publish without explicit user confirmation.

## 1. Version and changelog
- `pubspec.yaml` `version:` matches the release (e.g. branch `release/vX.Y.Z`).
- `CHANGELOG.md` has a `## X.Y.Z` section at the top describing every
  user-visible change. Breaking changes require a major bump and a
  "Breaking changes" sub-list with migration notes.
- `README.md` examples still compile against the current API.

## 2. Toolchain
```bash
fvm flutter pub get
(cd example && fvm flutter pub get)
fvm dart format --output=none --set-exit-if-changed lib test example/lib example/test
fvm flutter analyze
fvm flutter test
(cd example && fvm flutter test)
fvm flutter pub publish --dry-run
```
`pub publish --dry-run` warns about uncommitted files; that warning is
acceptable only while the tree is intentionally dirty. Any other warning is a
blocker (pub.dev score drops on analysis and dependency issues).

## 3. pub.dev score (must be 160/160)
pana scores a clean snapshot of the staged files (it runs `pub downgrade`, so
don't point it at the working copy):
```bash
fvm dart pub global activate pana
SNAP="$(mktemp -d)/pkg" && git checkout-index -a --prefix="$SNAP/"
FLUTTER_SDK="$HOME/fvm/versions/$(python3 -c 'import json;print(json.load(open(".fvmrc"))["flutter"])')"
(cd "$SNAP" && PATH="$FLUTTER_SDK/bin:$PATH" ~/.pub-cache/bin/pana --flutter-sdk "$FLUTTER_SDK" --no-warning .)
```
Anything below 160 is a blocker. The "Package does not support platform X"
lines refer to the pure-Dart runtime and are expected for a Flutter plugin
dependency; the Flutter platform score must still be 6/6. See
`.claude/rules/pub-dev-publishing.md` for what each category needs.

Also confirm the `--dry-run` file list contains no contributor-only files
(`CLAUDE.md`, `.claude/`, `.fvmrc`), and that the README snippets match the
current API.

## 4. Dependencies
- `fvm flutter pub outdated` — note anything outdated in the report.
- Every entry in `dependencies:` is imported somewhere in `lib/`
  (`grep -r "package:<name>" lib`). Unused dependencies are forced onto every
  consumer; remove them.
- `environment:` lower bounds are consistent (Dart SDK bound ↔ Flutter bound).

## 5. Code review
Delegate to the `flutter-code-reviewer` agent with:
"Review the diff between `main` and this branch for release X.Y.Z."

## 6. Report
Summarize: version, changelog status, each command's result, reviewer
verdict, and a final GO / NO-GO. Publishing (`fvm flutter pub publish`) and
tagging (`git tag vX.Y.Z`) happen only after the user says so.
