# AGENTS.md

## Purpose

This repository contains `bloc_small`, a Flutter package that simplifies the BLoC pattern on top of `flutter_bloc`.

The repo has two distinct parts:

1. `lib/`: the reusable package code published to pub.dev.
2. `example/`: a demo Flutter app that exercises the package features and contains generated app code.

Agents should treat the root package as the source of truth and use `example/` to verify package behavior, not to redefine package architecture.

## Read First

Before making changes, read these files:

1. `README.md`
2. `docs/project-overview-pdr.md`
3. `docs/codebase-summary.md`
4. `docs/code-standards.md`
5. `docs/system-architecture.md`

Use `docs/release-workflow.md` only for release or versioning work.

## Source Of Truth

If repository docs disagree, trust these in order:

1. Current source under `lib/` and `example/lib/`
2. `pubspec.yaml` and `example/pubspec.yaml`
3. `.github/workflows/ci.yml`
4. `README.md` and `docs/**`

This matters here because some docs and examples may lag behind the current SDK, version, or DI setup.

There is no repo-local `.opencode/` directory in this repository. If higher-level agent instructions mention repo-local workflow or rule files under `.opencode/`, do not assume they exist here. Use the files in this repository as the local authority instead.

## Project Snapshot

- Package name: `bloc_small`
- Current version: `4.0.0` (unreleased on this branch; pub.dev latest is `3.2.2`)
- Dart SDK: `^3.9.2`
- Flutter SDK: `>=3.38.0`
- CI Flutter version: `3.38.7`

Primary dependencies:

- `flutter_bloc`
- `get_it`
- `rxdart`
- `auto_route`
- `freezed_annotation`

`injectable` is **not** a dependency of this package. No file under `lib/` imports it, and
the DI integration lives entirely in the consuming app's own codegen. Do not re-add it to
the root `pubspec.yaml` to "fix" an example or consumer build — the example declares it
itself, which is the intended arrangement.

## Architecture Map

### Root package

- `lib/bloc_small.dart`
  - Main public entrypoint.
  - Re-exports this package's barrels, plus only the *specific* third-party symbols that appear in this package's own signatures (`GetIt`, `AutoRoute`, `PageRouteInfo`, and common `flutter_bloc` types). 4.0.0 stopped re-exporting `auto_route`, `flutter_bloc`, `freezed_annotation`, `get_it` and `injectable` wholesale — that leaked their full surface into consumers (`injectable`'s `test` annotation collided with `flutter_test`'s `test`) and turned any upstream breaking change into a silent one here. Add `show` clauses rather than whole-package exports.
- `lib/core/`
  - Internal foundations such as DI helpers, error handling, constants, and `ReactiveSubject` utilities.
- `lib/navigation/`
  - Navigation abstractions such as `INavigator` and `AppNavigator`.
- `lib/presentation/base/`
  - Base page classes, delegates, router base class, and loading overlay mixin.
- `lib/presentation/bloc/`
  - `MainBloc`, `CommonBloc`, event/state base classes.
- `lib/presentation/cubit/`
  - `MainCubit`.
- `lib/presentation/widgets/`
  - Reusable presentation widgets such as loading indicators.
- `lib/extensions/`
  - Public extensions exposed to consumers.

### Example app

- `example/lib/`
  - Demonstrates BLoC, Cubit, navigation, DI, and `ReactiveSubject` usage.
- `example/lib/bloc/`, `example/lib/cubit/`
  - Consumer-side usage examples.
- `example/lib/navigation/`
  - `auto_route` setup and generated routes.
- `example/lib/di/`
  - Injectable setup and generated registration code.

## Key Concepts To Preserve

Agents should preserve these package-level design decisions unless the task explicitly changes them:

- `MainBloc` and `MainCubit` are the main extension points for consumers.
- Shared behavior lives in base delegates and mixins, especially loading and error handling.
- `CommonBloc` manages loading state coordination.
- Navigation is abstracted instead of being hard-wired into widgets.
- `ReactiveSubject` is organized as a multi-part API using `part` files under `lib/core/utils/reactive_subject/`.
- Public API is curated through barrel exports and `lib/bloc_small.dart`.
- `catchError` / `blocCatch` / `cubitCatch` route `Exception` to `onError` but log **and rethrow** `Error`. This is deliberate: a bare `catch` previously absorbed `StateError`, `RangeError` and assertion failures, logged them, and continued as if the operation succeeded. Do not widen these back to a bare `catch` to make a test pass — loading state is cleared on both paths already.

## Edit Boundaries

### Safe places to change for package behavior

- `lib/core/**`
- `lib/navigation/**`
- `lib/presentation/**`
- `lib/extensions/**`
- `lib/bloc_small.dart`
- `test/**`
- `docs/**`

### Safe places to change for examples only

- `example/lib/**`
- `example/test/**`
- `example/README.md`

Do not treat example-only patterns as package internals unless the same behavior exists in root `lib/`.

## Generated And Derived Files

Do not hand-edit generated files unless the task explicitly requires it and regeneration is not possible.

Common generated files in this repo include:

- `example/lib/**/*.freezed.dart`
- `example/lib/navigation/app_router.gr.dart`
- `example/lib/di/di.config.dart`

If you change annotated example sources for Freezed, Injectable, or AutoRoute, regenerate code from `example/`.

Common annotated entrypoints that can require regeneration:

- `example/lib/di/di.dart`
- `example/lib/navigation/app_router.dart`
- `example/lib/bloc/**`
- `example/lib/cubit/**`

## Common Change Patterns

### If changing public API

Update all relevant locations:

1. Source files under `lib/`
2. Barrel exports such as `lib/core/core.dart`, `lib/navigation/navigation.dart`, `lib/presentation/presentation.dart`, or `lib/extensions/extensions.dart`
3. `lib/bloc_small.dart` if the symbol should be public
4. Tests
5. Documentation in `README.md` or `docs/` if consumer behavior changes

### If changing BLoC or Cubit base behavior

Check these files together:

- `lib/presentation/bloc/main_bloc.dart`
- `lib/presentation/cubit/main_cubit.dart`
- `lib/presentation/base/base_delegate.dart`
- `lib/presentation/bloc/common_bloc.dart`
- `lib/presentation/bloc/common_state.dart`
- `lib/core/error/**`

### If changing navigation behavior

Check these files together:

- `lib/navigation/app_navigator.dart`
- `lib/navigation/i_navigator.dart`
- `lib/presentation/base/base_app_router.dart`
- `lib/core/di/di.dart`
- `lib/extensions/app_navigator_extension.dart`

### If changing `ReactiveSubject`

Start from:

- `lib/core/utils/reactive_subject/reactive_subject.dart`

Then update the relevant `part` files next to it. Keep the API organized by concern instead of adding unrelated logic to a random part file.

### If changing dependency injection helpers

Check:

- `lib/core/di/di.dart`
- Any impacted example DI files under `example/lib/di/`

Be careful not to break package consumers that rely on `registerCore()` or `registerAppRouter()`.

Current DI behavior (4.0.0 changed this — earlier notes describing the opposite are stale):

- `registerAppRouter<T>()` **is** a complete router-registration path. It registers the passed instance under `T` via `registerSingleton`, then registers `BaseAppRouter`, `AppNavigator` and `INavigator` as lazy singletons resolving to it. Before 4.0.0 the argument was discarded and the body registered `() => get<T>()`, resolving a type nothing had registered — so even the happy path threw. Each of the four registrations is guarded by `isRegistered`, so calling it after other setup already registered one of them is safe.
- `registerCore()` registers `CommonBloc` as a **lazy singleton**, not a factory. `CommonBloc` holds app-wide loading state, so every page must observe the same instance; a factory would give each caller its own, making `showLoading()` on one invisible to the widget rendering another. Singleton identity is a correctness requirement here — do not "optimize" it to a factory.
- `registerCore()` is the only registration path for `CommonBloc`, and is deliberately not an `@module`: `injectable`'s generator does not scan modules declared inside a *package*, only those in the consuming app, so a module here would never reach a consumer's generated config.
- `resetCore()` unregisters `CommonBloc` and closes it first, so its stream controller is not leaked. It exists for tests and hot restart, where re-running DI setup would otherwise throw "already registered".
- Registration failures throw `DependencyRegistrationException`, which carries the original `cause`. Do not replace it with a bare `String` throw — that loses both the type and the stack trace at the point of failure.

## Testing Expectations

For root package changes, prefer this validation order:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

For CI-equivalent verification, use:

1. `flutter analyze`
2. `flutter test --coverage`

This mirrors the root package CI workflow only. It does not validate the example app.

### Compile-failure fixtures

`test/fixtures/**` is excluded from analysis in `analysis_options.yaml`, and the files
there are **deliberately broken**. `test/fixtures/analyze_fixtures_test.dart` shells out to
`dart analyze` and asserts each fixture is *rejected* — that is the only way to prove a
compile-time guarantee such as "a state manager without `IStateManager` fails to compile",
since no runtime test can observe it.

So: do not "fix" the errors in those fixtures, do not remove the `analyzer.exclude` entry,
and do not assume `flutter analyze` reporting clean means those files compile. A fixture
that starts analyzing cleanly is a regression in the guarantee it guards, and the test
fails loudly when that happens.

For example app changes, run commands from `example/`:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

Do not assume root CI covers example validation. The example app must be checked explicitly when it is affected.

If example generated sources are impacted, also run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Use that command from the `example/` directory unless the root package later adds the necessary generator dependencies.

## Release And Versioning

Only do release work when explicitly asked.

Relevant files:

- `pubspec.yaml`
- `CHANGELOG.md`
- `scripts/bump_version.dart`
- `scripts/generate_changelog.dart`
- `.github/workflows/ci.yml`

This repo uses conventional commits for automated version bumps:

- `feat:` -> minor
- `fix:` -> patch
- breaking changes -> major

Do not change release automation casually. CI already handles analyze, tests, changelog generation, release creation, and pub.dev publishing on push to `main` or `master`.

## Coding Conventions

Follow the repo docs and existing code style:

- Use `snake_case` file names.
- Use `PascalCase` for classes and mixins.
- Use `lowerCamelCase` for members.
- Prefer relative imports, matching `analysis_options.yaml`.
- Keep public API names simple and package-oriented.
- Reuse existing base classes and helpers before introducing new abstractions.
- Preserve documentation comments on public types and methods.

## Practical Rules For Agents

1. Keep changes minimal and local.
2. Do not introduce new architectural layers unless the task requires them.
3. Do not edit generated example files by hand when regeneration is the correct fix.
4. Do not add app-specific assumptions into the root package API.
5. When adding new public surface area, update exports and docs in the same change.
6. When changing behavior that affects consumers, prefer adding or updating tests before considering the task complete.
7. When touching both package code and example code, validate the package first and then the example.

## Quick Navigation Guide

- Want the public API entrypoint: `lib/bloc_small.dart`
- Want BLoC base behavior: `lib/presentation/bloc/main_bloc.dart`
- Want Cubit base behavior: `lib/presentation/cubit/main_cubit.dart`
- Want shared loading and error handling: `lib/presentation/base/base_delegate.dart`
- Want DI registration: `lib/core/di/di.dart`
- Want navigation abstraction: `lib/navigation/`
- Want reactive stream utilities: `lib/core/utils/reactive_subject/`
- Want consumer usage examples: `example/lib/`
- Want package tests: `test/`

## Definition Of Done

Unless the user explicitly asks for a docs-only draft or a partial answer, a solid change here usually means:

1. The correct source files were updated.
2. Public exports were checked.
3. Relevant tests were added or updated.
4. `flutter analyze` and `flutter test` were considered or run for the affected scope.
5. README or docs were updated if consumer-facing behavior changed.

## Language

Keep all repository content in English.
