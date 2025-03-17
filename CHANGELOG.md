# Changelog

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
