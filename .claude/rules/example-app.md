---
paths:
  - "example/**/*.dart"
---

# Example app (`example/`)

The example is documentation: keep it idiomatic clean architecture.

- Dependency direction: `presentation → domain ← data`. Files under
  `domain/` never import from `data/` or `presentation/`.
- Data models (`PostModel`) own JSON; domain entities (`PostEntity`) are
  plain immutable value objects. Repositories map model ↔ entity.
- Use cases expose a single `call(...)` method.
- Constructor injection everywhere; `GetIt` is used only in
  `lib/core/di.dart` (composition root).
- Widgets that subscribe to streams cancel them in `dispose()`.
- File names match the main class they contain.
