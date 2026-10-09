# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

The Flutter SDK is pinned with FVM (`.fvmrc`, currently 3.47.6). Always prefix with `fvm`.

```bash
fvm install                       # install the pinned SDK once
fvm flutter pub get               # root package
(cd example && fvm flutter pub get)

fvm flutter analyze               # analyzes lib/, test/ and example/
fvm dart format lib test example/lib example/test
fvm flutter test                  # library tests (test/*_test.dart)
fvm flutter test test/dio_network_call_executor_test.dart   # single file
(cd example && fvm flutter test)  # example widget test
(cd example && fvm flutter run)

fvm flutter pub publish --dry-run # publishing itself is done by a human
```

## Team Claude Code setup (tracked in git)

- `.claude/agents/flutter-code-reviewer.md` — reviewer agent (correctness, SOLID/DRY, public API, tests; runs the FVM toolchain). Run it before every PR.
- `.claude/skills/release-check/` — `/release-check` pre-publish checklist.
- `.claude/skills/dart-clean-code/` — `/dart-clean-code` where-to-put-what and SOLID/DRY guide.
- `.claude/rules/` — always-on and path-scoped rules (`lib/`, `example/`, `test/`, toolchain, pub.dev publishing).
- `.pubignore` — keeps contributor files (e.g. this `CLAUDE.md`) out of the pub.dev archive; it replaces `.gitignore` for publishing, so mirror new ignore rules in both.
- `.claude/settings.json` — shared permissions; personal overrides go in `.claude/settings.local.json` (gitignored).

## Architecture

This is a Flutter package (`viva_network_kit`) published to pub.dev. It wraps [Dio](https://pub.dev/packages/dio) with automatic connectivity checks before every HTTP request, returning results as `Either<ErrorType, ReturnType>` from the `dartz` package.

### Core abstractions (`lib/src/`)

- **`DioSerializer`** — abstract interface with two methods: `convertRequest(RequestOptions)` (returns the encoded body) and `convertResponse<ReturnType, SingleItemType>` (deserializes the Dio `Response`). **`ItemDeserializingSerializer`** implements the single-item vs. list logic once (Template Method); concrete serializers only provide `deserializeItem` and `wrapList`:
  - **`JsonSerializer`** — registry-based: callers call `addParser<MyModel>(MyModel.fromJson)` at startup; handles both single objects and lists.
  - **`DioBuiltValueSerializer`** — for projects using the `built_value` codegen package; uses `built_collection`'s `BuiltList` for list responses.

- **`NetworkErrorConverter<T>`** — abstract single-method interface (`convert(Exception) → T`). Consumers implement this to map `DioException` types and `ConnectionError` into their own error domain.

- **`ConnectionError`** — thin `Exception` subclass carrying a `ConnectionErrorType` enum (currently only `noInternet`) and a string `errorCode`. This is what gets passed to `NetworkErrorConverter` when offline.

- **`DioNetworkCallExecutor`** — the main entry point. Constructed with a configured `Dio` instance, a `DioSerializer`, and a `NetworkErrorConverter`. It:
  1. Subscribes to the `connectivity_plus` stream to cache connectivity state (unless an initial `connectivityResult` is passed); `dispose()` cancels it. `Connectivity` is injectable for tests.
  2. Every method (`get`, `post`, `put`, `patch`, `delete`, `execute`) delegates to the private `_guardedRequest` pipeline: fresh `checkConnectivity()` → `Left(ConnectionError)` if offline → Dio call → `Right(convertResponse(...))`, or `Left(errorConverter.convert(e))` on any `Exception`.
  3. "Online" means any `ConnectivityResult` other than `none` (`ConnectivityResult.isConnected()`).

### Public API surface (`lib/viva_network_kit.dart`)

Exports `ConnectionError`, `DioNetworkCallExecutor`, `DioSerializer`, `ItemDeserializingSerializer`, `JsonSerializer`, `NetworkErrorConverter`, `SerializationException`, and re-exports everything from `connectivity_plus`. Deserialization failures reach `NetworkErrorConverter` as `SerializationException`.

`DioBuiltValueSerializer` is **not** exported from the main barrel — import it directly from `lib/src/dio_built_value_serializer.dart` when needed.

### Example app (`example/`)

Demonstrates the clean-architecture pattern: `presentation → domain ← data`. The domain layer uses `PostEntity`; the data layer's `PostModel` maps to it. Uses BLoC (`flutter_bloc`) and `get_it`; all wiring is in `example/lib/core/di.dart` (composition root) and everything else uses constructor injection. Error types are `BaseError`/`ErrorCode` in `example/lib/core/utils/exception/`.

## Publishing

Version is in `pubspec.yaml`. Update `CHANGELOG.md` before publishing; run `/release-check`. The package publishes to `https://pub.dev` (not a private registry).
