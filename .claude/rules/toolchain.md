# Toolchain

- The Flutter SDK is pinned in `.fvmrc`. Always run `fvm flutter ...` /
  `fvm dart ...`, never a bare `flutter`/`dart`, so everyone (and CI) uses the
  same analyzer and formatter.
- After changing Dart code, run `fvm dart format` on the touched files and
  `fvm flutter analyze` before calling the work done.
- To change the pinned version: `fvm use <version>`, then re-run analyze and
  both test suites and note the change in `CHANGELOG.md`.
