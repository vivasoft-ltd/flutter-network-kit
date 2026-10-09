---
name: dart-clean-code
description: Clean-code, SOLID, DRY and design-pattern guide for writing or refactoring Dart code in viva_network_kit and its example app. Use when adding a feature, HTTP method, serializer, error converter, or refactoring existing code.
---

# Writing code in viva_network_kit

## Where things go
| Need | Do this |
|---|---|
| New HTTP verb / request variant | Add a thin public method that calls `_guardedRequest(() => dio.<verb>(...))` in `lib/src/dio_network_call_executor.dart`. Never copy the connectivity/try-catch block. |
| New response format | Extend `ItemDeserializingSerializer` and implement `deserializeItem` + `wrapList` (Template Method). Implement `DioSerializer` directly only if single/list detection differs. |
| New error domain | Implement `NetworkErrorConverter<T>` in the consuming app, not in the library. |
| New public type | Put it in `lib/src/`, export it from `lib/viva_network_kit.dart`, add dartdoc and a CHANGELOG entry. |
| New example feature | `domain/` (entity, repository interface, use case) → `data/` (model with `fromJson`/`toEntity`, data source, repository impl) → `presentation/` (bloc + view); wire it in `example/lib/core/di.dart`. |

## Principles as applied here
- **SRP** — executor = orchestration only; serializer = (de)serialization
  only; converter = error mapping only.
- **OCP** — extend through the `DioSerializer` / `NetworkErrorConverter`
  interfaces; consumers should never need to edit the executor.
- **LSP** — implementations honor the interface contract: `convertRequest`
  takes `RequestOptions`, returns the encoded body, never the options.
- **ISP** — keep interfaces to one or two methods, as they are now.
- **DIP** — constructor-inject `Dio`, `Connectivity`, serializers and
  converters (with production defaults where helpful, e.g.
  `Connectivity? connectivity`). No service locator lookups inside classes;
  `GetIt` is used only in the example's composition root.
- **DRY** — if a block of 3+ lines repeats with only a value changing,
  extract a private helper that takes the varying part (a closure, a type
  parameter, or a value). Duplicated *knowledge* (e.g. "what counts as
  online") must live in exactly one place (`ConnectivityResult.isConnected`).
- **YAGNI** — no new abstraction until there's a second implementation or a
  test needs the seam.

## Dart conventions
- Prefer `final`, `const` constructors, and `required` named params for
  constructors with more than two arguments.
- Use exhaustive `switch` expressions over `sealed` classes instead of
  `if/else is` chains.
- No `!` on data that comes from the network or JSON; validate and throw a
  descriptive error (`StateError`, `FormatException`) instead.
- Cancel every `StreamSubscription` you create; expose `dispose()` if the
  owner isn't a widget.
- Public members get `///` dartdoc that explains *why*/*when*, not a
  restatement of the signature.

## Done means
`fvm flutter analyze` clean, `fvm dart format` clean, new behavior covered
by a test using `test/helpers/fakes.dart`, CHANGELOG updated for
user-visible changes. Then run the `flutter-code-reviewer` agent.
