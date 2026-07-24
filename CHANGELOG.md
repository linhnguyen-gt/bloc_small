# Changelog

## 4.0.0

*Released on 2026-07-19*

Correctness release. Fixes 9 critical, 21 important and 12 minor defects found in a
2026-07-19 audit, several of which existed because the documentation and the
implementation disagreed. Every critical fix carries a regression test that was verified
failing before the fix landed.

**This release is breaking.** Read the migration guide below before upgrading.

### ⚠️ Read this first: previously-hidden errors will now surface

`catchError` / `blocCatch` / `cubitCatch` used a bare `catch`, which absorbed `Error` as
well as `Exception` — `StateError`, `RangeError`, assertion failures — logged them, and
continued as if the operation had succeeded. A cubit closed during an `await` would throw
`StateError` on `emit`, get swallowed, and leave stale UI with no crash report.

`Error` is now logged **and rethrown**, so it reaches your zone handler and crash reporter.
`Exception` is still routed to `onError` as before, and loading state is still cleared
either way.

**Apps that were silently swallowing bugs will start reporting them.** That is the fix
working, not a regression introduced by 4.0.0.

### Breaking changes

#### Pages

`BasePageStatelessDelegate` is now a `StatefulWidget`, and `buildPage` receives the state
manager as an argument. It was a `StatelessWidget` holding `late final` dependency fields;
Flutter may rebuild a widget at any time, and the new instance resolved its own state
manager while the element tree kept providing the original — so `bloc.add(...)` could send
events to an instance nothing rendered.

```dart
// Before (3.x)
class MyHomePage extends BaseBlocPage<MyBloc> {
  MyHomePage({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: Scaffold(
        body: BlocBuilder<MyBloc, MyState>(
          builder: (context, state) => Text('${state.count}'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => bloc.add(const Increment()),   // field getter
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// After (4.0.0)
class MyHomePage extends BaseBlocPage<MyBloc> {
  const MyHomePage({super.key});                          // const works again

  @override
  Widget buildPage(BuildContext context, MyBloc bloc) {   // handed to you
    return buildLoadingOverlay(
      child: Scaffold(
        body: BlocBuilder<MyBloc, MyState>(
          builder: (context, state) => Text('${state.count}'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => bloc.add(const Increment()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
```

The same change applies to `BaseCubitPage`, where the second parameter is your cubit.
`BaseBlocPageState` / `BaseCubitPageState` (the `StatefulWidget` variants) are unchanged —
they keep `buildPage(BuildContext)` and their `bloc` / `cubit` getters.

* The `const` page constructor the docs have always shown now actually compiles.
* `BaseBlocPage.bloc` and `BaseCubitPage.cubit` getters are removed; use the argument.

#### Bloc ownership

**The DI container owns every bloc and cubit. Widgets no longer close them.**

Pages now provide their state manager with `BlocProvider.value` instead of
`BlocProvider(create:)`. Previously the widget became the owner and closed the bloc on
pop, while GetIt kept handing out the closed instance — so pushing the page a second time
used a dead bloc.

* **`registerFactory` is no longer supported for a page's state manager.** Register it with
  `registerSingleton` / `registerLazySingleton` (or `@singleton` / `@lazySingleton`).
  Factory instances are never disposed by GetIt, and post-change nothing else would either.
  Debug builds throw a `StateError` naming the fix at page build time.
* `CoreModule` is deleted. `registerCore()` now registers `CommonBloc` as a lazy singleton
  and is the only registration path — a `@module` inside a package is never scanned by a
  consuming app's `injectable` codegen, so it never worked.
* `resetCore()` added, for tests and hot restart.
* `BaseDelegate.dispose()` is removed. It set `navigator = null` on what is now an app-wide
  singleton, so wiring it to page teardown would have disabled navigation app-wide on the
  first pop.
* `CommonBloc` no longer carries a `navigator`. Every page wrote its own navigator onto the
  shared singleton, so the last page pushed silently won for the whole app.

#### Remove `@LazySingleton` / `@Injectable` from your router

`registerAppRouter` previously **discarded** the router you passed it, so annotating the
router for `injectable` codegen was the only thing that actually registered it. Now that
`registerAppRouter` registers the instance it is handed, keeping the annotation registers
the router twice and `getIt.init()` throws `Type AppRouter is already registered`.

```dart
// Before (3.x)
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@LazySingleton()                                   // <- remove this
class AppRouter extends BaseAppRouter { ... }

// After (4.0.0)
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends BaseAppRouter { ... }
```

Re-run `dart run build_runner build --delete-conflicting-outputs` afterwards.

#### New `IStateManager<S>` bound

Base pages now bind `B extends IStateManager<Object?>` instead of
`StateStreamableSource<Object?>`, replacing an internal `di<B>() as dynamic` cast. Types
extending `MainBloc` / `MainCubit` satisfy it automatically; a type that does not now fails
to **compile** rather than at runtime.

#### Loading state

`CommonState.loadingStates` changed from `Map<String, bool>` to `Map<String, int>` — a
reference count, not a flag. Two concurrent operations on one key previously left the
spinner hidden as soon as the *first* finished.

* Visible while the count is `> 0`; floors at zero; keys are **removed** at zero (they
  previously leaked one map entry per operation forever).
* New `ClearComponentLoading(key:)` event force-clears a key regardless of count. The 30s
  safety timeout uses it — a single decrement could not dismiss a spinner held by two
  operations.
* The safety timeout is now a cancellable `Timer` scoped to the operation that armed it.
  It was an uncancellable `Future.delayed` closing over stale state, so a timer armed at
  t=0 fired at t=30s and dismissed whatever spinner happened to be showing.
* `CommonState.hashCode` now combines entries order-independently, matching its `==`.
  Equal states previously produced different hashes and both survived in a `Set`.
* `LoadingOverlayMixin.hideLoading` removed; the mixin no longer requires a `commonBloc`
  member and reads `CommonBloc` from the build context.
* `BaseCubitPageState.hideLoading` removed. It had no matching `showLoading`, so under
  refcounting it decremented a key the page never incremented — dropping the spinner while
  the operation that raised it was still running. `BaseBlocPageState` never had it. Hide
  loading from the cubit that showed it (`cubitCatch`, or `hideLoading` on the delegate)
  so every decrement pairs with an increment.
* `BaseCubitPageState.buildLoadingOverlay` no longer accepts a `timeout` parameter, for
  consistency with every other page class. The safety timeout is fixed at 30 seconds.
* `AnimatedOpacity` removed from the overlay. It never animated — the widget only existed
  while loading and its opacity was hard-coded to `1.0`.

#### Error handling

* Four overlapping names collapse into one mixin: **`BaseErrorHandlerMixin`**. Removed:
  `BlocErrorHandlerMixin`, `CubitErrorHandlerMixin` (byte-identical to each other) and
  `CubitErrorHandler`. Replace any of them with `with BaseErrorHandlerMixin`.
* `handleError` no longer calls `hideLoading()`. `catchError`'s `finally` owns hiding and is
  the only place guaranteed to pair with the matching `showLoading`; doing both
  double-decremented the new refcount.
* `retryOperation<T>` now returns `Future<T>` instead of `Future<void>` — it previously
  declared `<T>` and discarded the value it had just awaited.
* `retryOperation` retries on `Exception` only. Retrying on `Error` re-ran side effects,
  so an emit-after-close `StateError` produced three duplicate requests.
* `TimeoutException` renamed to **`AppTimeoutException`**. The old name shadowed
  `dart:async`'s, which made every `error is TimeoutException` branch dead for the timeouts
  the SDK actually throws. `getErrorMessage` now matches both.
* New `sealed class AppException` base with a real `toString()`. `NetworkException`,
  `ValidationException` and `AppTimeoutException` extend it, so they can be caught as a
  group and `e.toString()` shows the message instead of `Instance of 'NetworkException'`.

#### Navigation

* `clearAndPush` no longer pushes a second copy of the route. It called `replaceAll([route])`
  then `push(route)`, leaving two entries so "back" reached a duplicate instead of exiting.
  It is now equivalent to `replaceAllWith`, as its documentation always claimed.
* `popUntil` now pops to the **existing** route instead of clearing the stack and pushing a
  fresh instance. The old behaviour discarded the target's state and left the `Future`
  returned by its original `push` uncompleted forever.
* `INavigator` is now the type resolved from DI, so navigation can be faked in widget
  tests. It previously existed but nothing resolved it, so a mock was never picked up.
* `GetIt.getNavigator()` returns `INavigator` instead of `AppNavigator`. Code holding the
  result in an `AppNavigator`-typed variable, or reading `enableNavigationLogs`, must
  resolve `AppNavigator` explicitly — it is still registered under its own type.
* Navigation methods return non-nullable futures (`Future<void>` rather than
  `Future<void>?`). The nullability only existed because an internal helper was typed
  `void` instead of `Never`.

#### Re-exports trimmed

`bloc_small` no longer re-exports `auto_route`, `flutter_bloc`, `freezed_annotation`,
`get_it` and `injectable` wholesale. That leaked their entire surface into every consumer —
`injectable`'s `test` annotation collided with `flutter_test`'s `test` function, making any
test file importing both fail to compile — and turned any breaking change in those packages
into a silent breaking change here.

Add whichever you use directly:

```yaml
dependencies:
  auto_route: ^11.1.0
  freezed_annotation: ^3.1.0
  get_it: ^9.2.0
  injectable: ^2.6.0
```

```dart
import 'package:auto_route/auto_route.dart';       // @RoutePage, AutoRoute, PageRouteInfo
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';        // @injectable, @lazySingleton
```

Still re-exported, because they appear in this package's own signatures: `GetIt`,
`AutoRoute`, `PageRouteInfo`, and the common `flutter_bloc` types (`Bloc`, `Cubit`,
`BlocBuilder`, `BlocProvider`, `Emitter`, …).

#### `injectable` is no longer a dependency of this package

Dropping the wholesale re-export left `injectable` declared but unused — no file under
`lib/` imports it. It stayed in `dependencies` only to feed the old export, so keeping it
would have forced a DI-framework choice, and every future `injectable` major, onto
consumers that may not use it at all.

`bloc_small` works with `injectable` exactly as before — `registerCore()`, `@module`
registrations and `@injectableInit` are unaffected, since that integration always lived in
the consuming app's own codegen. Apps that use the annotations simply declare the package
themselves, as the re-export section above already instructs:

```yaml
dependencies:
  injectable: ^2.6.0   # or ^3.0.0 — bloc_small no longer constrains this
```

Apps that resolved `injectable` transitively through `bloc_small` without declaring it
will need to add that line.

#### Web support

* `checkCompatibility()` removed. It was dead logic — `Platform.version.startsWith('2')`
  cannot be true under `sdk: ^3.9.2` — and its `dart:io` import broke web builds outright.
* `LoadingIndicator` uses `defaultTargetPlatform` instead of `Platform.isIOS`.
* **The package now builds for Flutter Web.** CI builds the example for web so this cannot
  silently regress.

#### ReactiveSubject

* Derived subjects own their upstream subscription and cancel it on `dispose()`, and
  forward `onDone` so disposing a parent closes its children. Operators previously leaked
  the subscription in one direction and left listeners hanging forever in the other.
* `switchMap` and `onErrorResumeNext` no longer allocate a `ReactiveSubject` per event.
* `cache()` rebuilt on a replaying subject — its own documented example did not work.
* `shareReplay(maxSize:)` replays `maxSize` items instead of degrading to one.
* `groupBy` deep-copies on emit; snapshots no longer mutate retroactively.
* Nullable `T` is handled correctly: `ReactiveSubject<String?>()..add(null)` now reports
  `hasValue == true` and returns `null` from `.value` instead of throwing.
* `valueOrNull` on a fresh subject returns `null` instead of throwing
  `LateInitializationError`.
* `startWith(0)` then `add(1)` emits `[0, 1]`. It previously double-seeded and emitted
  `[0, 0, 1]`.
* `addError()` respects the same dispose guard as `add()`.
* The `sink` getter now returns a guard that routes through `add()`. It previously exposed
  the raw underlying sink, bypassing the dispose guard and value tracking, so
  `s.sink.add(42)` left `s.value` stale. The static type is unchanged, so this is a silent
  behaviour change — note in particular that **`sink.close()` now disposes the subject**
  (cancelling its subscriptions and clearing its value), where it previously closed only
  the underlying stream controller.
* **Disposing a source now clears its derived subjects' cached values.** `onDone` is
  forwarded, so a child disposes with its parent — and `dispose()` clears the cached value.
  Reading `.value` on a derived subject after its source was disposed now throws
  `StateError` where 3.x returned the last value:

  ```dart
  final doubled = source.map((v) => v * 2);
  await source.dispose();
  doubled.value;        // 3.x: last value.  4.0.0: throws StateError
  doubled.valueOrNull;  // 3.x: last value.  4.0.0: null
  ```

  Read derived values before tearing down the source, or guard with `isDisposed`.
* `switchMap` now **disposes** the subject its mapper returns when the next source event
  arrives, instead of leaking it. If your mapper returns a shared or long-lived subject
  rather than a fresh one, it will now be disposed out from under you — return a fresh
  subject per call.
* `retry()` has a documented limitation: re-subscribing to a `BehaviorSubject`-backed
  source replays the cached value rather than re-running the work. Documented rather than
  given a cosmetic fix.
* `distinctBy` is "distinct by every key seen so far", not "distinct until changed". The
  documentation now says so, and the unbounded growth of its key set is called out. Behaviour
  is unchanged deliberately — altering it would silently change output for running code.

### Fixes not affecting the public API

* `registerAppRouter` now registers the router instance it is handed. It discarded the
  argument and registered `() => get<T>()` for a `T` nothing had registered, so resolving
  `BaseAppRouter` or `AppNavigator` threw even on the happy path.
* Registration failures throw a typed `DependencyRegistrationException` (or `ArgumentError`)
  instead of a bare `String`, preserving type and stack trace.
* `reset()` on a closed bloc or cubit no longer throws, matching the guard already on `add()`.
* `avoid_dynamic_calls` and `use_build_context_synchronously` lints enabled; the removed
  `prefer_equal_for_default_values` lint (deleted in Dart 3.0) no longer warns.
* Unused `plugin_platform_interface` dependency removed; `repository` and `issue_tracker`
  added. The `flutter: ">=3.38.0"` constraint is unchanged — it is tight for a library, but
  lowering it without building against an older SDK would be an unverified claim.

## 3.2.2

*Released on 2026-01-19*

### Fixes

* **ci**: checkout release tag in publish job to ensure correct version ([dd40a05](https://github.com/linhnguyen-gt/bloc_small/commit/dd40a05385b73aea29ac77f195f5c018de526f18))

## 3.2.1

*Released on 2026-01-19*

### Fixes

* **ci**: correct changelog extraction logic for release notes ([049a261](https://github.com/linhnguyen-gt/bloc_small/commit/049a2619108ca2908c174868853b1fb278c2fe5d))

## 3.2.0

*Released on 2026-01-19*

### Features

* implement automated CI/CD release workflow and refactor codebase ([04a7754](https://github.com/linhnguyen-gt/bloc_small/commit/04a7754ad0430d1021d39faf86f9a3a6527964c0))

### Fixes

* correct version extraction in CI/CD workflow ([d674c28](https://github.com/linhnguyen-gt/bloc_small/commit/d674c2815f0973de2e534dec8ccefd59b4c6b0e4))
* update test to match new ReactiveSubject disposal behavior ([97dc3c9](https://github.com/linhnguyen-gt/bloc_small/commit/97dc3c99d6874e4ee3d2ad24f2d72f408fc06724))
* resolve all linting issues for CI/CD ([8358151](https://github.com/linhnguyen-gt/bloc_small/commit/8358151734658567dbc28ec0becb4d6a7d7641fd))
* resolve injectable_generator dependency conflict ([fb4cdc0](https://github.com/linhnguyen-gt/bloc_small/commit/fb4cdc04ef5e17ffe5844ebd435221b3860b96c5))
* resolve build_runner dependency conflict in example ([1a3ae45](https://github.com/linhnguyen-gt/bloc_small/commit/1a3ae453ae3e0306ca012321621f4c7a36650552))

### Other

* upgrade Flutter to 3.38.7 and update all packages ([6587aa2](https://github.com/linhnguyen-gt/bloc_small/commit/6587aa23b5f92d8136af9e6eea2fe3918ef777ed))
* add RxDart 0.28.0 enhancements to ReactiveSubject with comprehensive demo ([fcc4ec0](https://github.com/linhnguyen-gt/bloc_small/commit/fcc4ec069ec32f8b79e38ee193a3bc953356c284))

## 3.1.1

* Upgrade dependencies

## 3.1.0

* BasePageDelegate (base_page_delegate.dart):
  * Renamed bloc property to stateManager for better semantic clarity
  * Updated documentation to reflect that it can be both a Bloc or Cubit
  * Updated MultiBlocProvider to use the new variable name
* BaseBlocPageState (base_bloc_page_state.dart):

  * Added a strongly-typed bloc getter that returns stateManager with the correct Bloc type
  * Updated method calls to use the typed bloc getter instead of casting
  * Enhanced documentation with proper usage examples
* BaseCubitPageState (base_cubit_state.dart):
  * Added a strongly-typed cubit getter that returns stateManager with the correct Cubit type
  * Updated method calls to use the typed cubit getter instead of casting
  * Updated documentation with proper usage examples
* Clean folder

## 3.0.2

* Update package dependencies:
  * flutter_bloc to ^9.1.0
  * mockito to ^5.4.6
* Improve logging and error handling in AppNavigator
* Update example project configurations and dependencies
* Fix generated code compatibility (Freezed and auto_route generated files)\
* Update "Constructors for public widgets should have a named 'key' parameter.
Try adding a named parameter to the constructor.dartuse_key_in_widget_constructors"

## 3.0.1

* Fix freezed import
* Fix readme

## 3.0.0

### Breaking Changes

* Migrated to Freezed 3.0.0
  * Required `sealed` keyword for pattern matching classes
  * Removed `.when()` and `.map()` methods in favor of Dart's built-in pattern matching
  * Updated all Freezed classes to use new syntax
* Improved ReactiveSubject implementation
  * Added explicit type arguments for Stream generics
  * Enhanced error handling and recovery mechanisms
  * Added `listen` method for better stream control

### Documentation

* Updated examples to use Dart's pattern matching syntax
* Added migration guide for Freezed 3.0.0
* Enhanced ReactiveSubject documentation with new examples

### Migration Guide

* Add `sealed` keyword to all Freezed classes using pattern matching
* Replace `.when()` and `.map()` with Dart's switch expressions
* Update ReactiveSubject usage to include explicit type arguments

## 2.2.3

* Upgrade flutter
* Remove test helper

## 2.2.2

* Fixed package validation issues
* Added proper test support
* Updated dependencies to latest versions
* Improved documentation

## 2.2.1

### Features

* Added `BlocErrorHandlerMixin` for standardized error handling
* Improved error logging and management
* Added support for common exception types (NetworkException, ValidationException, TimeoutException)

### Bug Fixes

* Fixed loading state management between screens
* Fixed error handling in blocCatch
* Improve DI
* Improve Bloc Test

### Documentation

* Added error handling section in README
* Added examples for BlocErrorHandlerMixin usage
* Updated error handling best practices

## 2.2.0

### Features

* Added StatelessWidget support with `BaseBlocPage` and `BaseCubitPage`
* Added `BasePageStatelessDelegate` for common StatelessWidget functionality
* Maintained feature parity with StatefulWidget implementations including:
  * Dependency injection
  * Loading overlay management
  * Navigation support
  * BLoC/Cubit pattern integration

### Documentation

* Updated README with StatelessWidget usage examples
* Added comparison between StatelessWidget and StatefulWidget approaches
* Added code examples for both BLoC and Cubit with StatelessWidget

## 2.1.2

* Hotfix `BlocContext` extension for BlocProvider and BlocListener

## 2.1.1

* Reorganized and consolidated exports into a single file
* Improved package organization and maintainability
* Removed separate export files for third-party packages
* Added clear export grouping with documentation
* Add logs navigator and type key

## 2.1.0

### Breaking Changes

* Renamed `BasePageState` to `BaseBlocPageState` for better clarity

### Features

* Added Cubit implementation with counter example
* Added `BaseCubitPageState` for Cubit pattern support
* Added error handling with `cubitCatch`
* Added loading state integration for Cubits
* Improved class naming consistency

### Documentation

* Updated README with Cubit usage section
* Added comparison between BLoC and Cubit patterns
* Added new examples for both BLoC and Cubit approaches
* Added migration guide for existing code

### Migration Guide

* Replace `BasePageState` with `BaseBlocPageState`
* Consider using Cubit for simpler features
* Update imports to use new class names

## 1.1.0

* add sample code
* upgrade flutter
* update readme
* update api reactive subject
