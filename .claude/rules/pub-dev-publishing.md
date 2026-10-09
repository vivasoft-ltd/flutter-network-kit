---
paths:
  - "pubspec.yaml"
  - "README.md"
  - "CHANGELOG.md"
  - "LICENSE"
  - ".pubignore"
  - "lib/**/*.dart"
---

# pub.dev publishing rules

The package must keep the full **160/160 pub points** (checked with `pana`, see
the `release-check` skill). What each category needs:

| pana category | Points | Keep it green by |
|---|---|---|
| Follow Dart file conventions | 30 | Valid `pubspec.yaml` (description 60–180 chars, `homepage`/`repository`/`issue_tracker` reachable, ≤5 `topics`); `README.md`, `CHANGELOG.md` with an entry for the current version; OSI `LICENSE` (MIT). |
| Provide documentation | 20 | ≥20% of public API has `///` dartdoc (aim for 100% of exported types and public members); `example/` contains a runnable app (`example/lib/main.dart`). |
| Platform support | 20 | Don't import `dart:io`/`dart:html` or platform-specific packages from `lib/` without conditional imports. |
| Pass static analysis | 50 | `fvm flutter analyze` clean **and** `fvm dart format` clean (formatting issues lose points). |
| Up-to-date dependencies | 40 | Constraints accept the latest version of every dependency; supports the latest stable SDK; `pub downgrade` (lower bounds) still analyzes clean. |

Also:
- **Archive contents**: `.pubignore` replaces the root `.gitignore` for
  publishing, so new ignore rules must be added to **both**. Contributor-only
  files (`CLAUDE.md`, tooling) go in `.pubignore`. Check with
  `fvm flutter pub publish --dry-run`.
- **README code must compile** against the current API; update it in the same
  change as any public API change.
- **Semver**: breaking public API change → major; new API → minor; fixes → patch.
  The version is final once published (pub.dev never allows re-publishing a
  version), so get CHANGELOG and README right before publishing.
- Never run `pub publish` (without `--dry-run`) from Claude; a maintainer publishes.
