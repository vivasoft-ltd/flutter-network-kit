## 2.2.0

- fixed: ethernet, VPN and other non-wifi/mobile connections were treated as offline; any `ConnectivityResult` other than `none` now counts as connected
- fixed: `DioBuiltValueSerializer.convertRequest` serialized the `RequestOptions` instead of the request body when used through `execute`
- fixed: `JsonSerializer.convertRequest` threw for `Map`/`List` bodies; non-`Serializable` data is now passed through and lists of `Serializable` are encoded
- fixed: response deserialization failures (missing `JsonSerializer` parser, payload/model mismatch) no longer escape the `Either`; they are passed to `NetworkErrorConverter.convert` as the new `SerializationException` and returned as `Left`
- `ConnectivityResult.isConnected()` now returns `true` for any result other than `none` (previously only wifi/mobile)
- added `DioNetworkCallExecutor.dispose()` to cancel the connectivity subscription
- added optional `connectivity` constructor parameter to `DioNetworkCallExecutor` for testing
- `put`, `patch` and `delete` now accept any `body` (previously `Map<String, dynamic>?`), matching `post`
- refactored: all HTTP methods share one request pipeline; `JsonSerializer` and `DioBuiltValueSerializer` now extend the new `ItemDeserializingSerializer` base (custom serializers can extend it too)
- `DioSerializer`, `ItemDeserializingSerializer` and `SerializationException` are now exported from `viva_network_kit.dart`
- removed unused `get_it` dependency
- fixed missing return type lint on `JsonSerializer.addParser` flagged by pub.dev static analysis
- updated dio, built_value, connectivity_plus, and flutter_lints to latest versions
- raised minimum supported SDK to Dart 3.2 / Flutter 3.16 (required by connectivity_plus 7.x)
- added unit tests for the executor and both serializers
- added dartdoc to the public API and rewrote the README for the current API
- example: domain layer now uses `PostEntity`, constructor injection throughout, and a working widget test

## 2.1.8

- code refactoring for cleaner code
- updated pubspec.yaml

## 2.1.7

- updated readme.md
