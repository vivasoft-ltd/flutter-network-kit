---
paths:
  - "lib/**/*.dart"
---

# Library code (`lib/`)

- This is a published package. Anything exported from
  `lib/viva_network_kit.dart` is public API: don't rename, remove, or narrow
  it without a major version bump. Widening (e.g. `Map? body` → `dynamic
  body`) and adding optional parameters are fine.
- All HTTP methods must route through `_guardedRequest`; do not duplicate the
  connectivity check or try/catch.
- "Online" is defined only by `ConnectivityResult.isConnected()`
  (`!= none`). Don't re-implement it.
- Inject dependencies via constructors with optional overrides for testing
  (see `Connectivity? connectivity`). No `GetIt` in `lib/`.
- Every dependency in `pubspec.yaml` must be imported from `lib/`.
- Any user-visible change needs a `CHANGELOG.md` entry under the current
  version.
