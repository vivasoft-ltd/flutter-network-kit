---
paths:
  - "test/**/*.dart"
  - "example/test/**/*.dart"
---

# Tests

- Test files end in `_test.dart` (otherwise `flutter test` skips them).
- No real network or platform channels. Use `FakeConnectivity`,
  `FakeAdapter` (a Dio `HttpClientAdapter`) and `PassThroughErrorConverter`
  from `test/helpers/fakes.dart`.
- One behavior per test; name tests after the behavior
  ("returns Left(ConnectionError) when offline"), structured
  arrange / act / assert.
- Every bug fix in `lib/` gets a regression test.
