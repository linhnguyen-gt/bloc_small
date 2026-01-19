# Changelog

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
