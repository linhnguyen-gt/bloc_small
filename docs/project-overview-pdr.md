# Project Overview & Product Development Requirements (PDR)

## Project Summary

**bloc_small** is a lightweight Flutter package that provides a simplified and streamlined implementation of the BLoC (Business Logic Component) pattern. Built on top of `flutter_bloc`, it reduces boilerplate code while maintaining the core benefits of reactive state management.

### Version
- **Current Version**: 3.1.1
- **Dart SDK**: ^3.9.2
- **Flutter**: >=3.3.0

## Product Vision

Create an intuitive, developer-friendly state management solution that:
- Simplifies BLoC pattern implementation
- Reduces boilerplate code
- Provides built-in loading states and error handling
- Supports both BLoC and Cubit patterns
- Integrates seamlessly with dependency injection and navigation

## Core Features

### 1. Simplified BLoC Pattern
- Base classes (`MainBloc`, `MainCubit`) that extend `flutter_bloc`
- Automatic resource management and disposal
- Built-in lifecycle hooks

### 2. State Management
- Support for both BLoC (event-driven) and Cubit (direct state mutations)
- Freezed integration for immutable state classes
- Type-safe state updates

### 3. Loading State Management
- Global and component-specific loading indicators
- Automatic loading overlay management
- Configurable loading keys

### 4. Error Handling
- Standardized error handling with `blocCatch` and `cubitCatch`
- Built-in exception types (NetworkException, ValidationException, TimeoutException)
- Error handler mixin for consistent error management

### 5. Navigation Integration
- Optional `auto_route` integration for type-safe navigation
- Platform-adaptive transitions
- Deep linking support
- Clean navigation API

### 6. Dependency Injection
- GetIt and Injectable integration
- Core module registration
- Router registration helpers

### 7. Reactive Programming
- `ReactiveSubject` wrapper around RxDart
- Stream transformation methods
- Time control operators (debounce, throttle)
- Error recovery mechanisms

### 8. Widget Support
- `BaseBlocPageState` / `BaseCubitPageState` for StatefulWidget
- `BaseBlocPage` / `BaseCubitPage` for StatelessWidget
- Automatic dependency injection
- Built-in loading overlay support

## Technical Requirements

### Dependencies
- `flutter_bloc: ^9.1.1` - Core BLoC functionality
- `get_it: ^9.0.5` - Dependency injection
- `injectable: ^2.6.0` - Code generation for DI
- `rxdart: ^0.28.0` - Reactive programming
- `auto_route: ^11.1.0` - Type-safe navigation (optional)
- `freezed_annotation: ^3.1.0` - Immutable classes

### Dev Dependencies
- `flutter_lints: ^6.0.0` - Linting rules
- `mockito: ^5.4.5` - Mocking for tests
- `bloc_test: ^10.0.0` - BLoC testing utilities

## Target Audience

- Flutter developers using BLoC pattern
- Teams looking to reduce boilerplate in state management
- Projects requiring consistent error handling and loading states
- Applications needing type-safe navigation

## Success Metrics

1. **Developer Experience**
   - Reduced boilerplate code by 40-60%
   - Faster feature development
   - Consistent patterns across codebase

2. **Code Quality**
   - Type safety with Freezed
   - Comprehensive error handling
   - Test coverage >80%

3. **Performance**
   - Minimal overhead over base `flutter_bloc`
   - Efficient loading state management
   - Proper resource disposal

## Non-Goals

- Not a replacement for `flutter_bloc` (built on top of it)
- Not a full framework (focused on state management)
- Not opinionated about UI structure
- Not providing data layer (focused on presentation layer)

## Example Application

A comprehensive example application is included in the `example/` directory, demonstrating:
- Complete BLoC and Cubit implementations
- Navigation setup with auto_route
- Dependency injection configuration
- Loading state management
- Error handling patterns
- 12+ ReactiveSubject use cases

See [example/README.md](../example/README.md) for detailed documentation.

## Future Considerations

- Enhanced testing utilities
- More navigation integrations
- Additional reactive operators
- Performance optimizations
- Enhanced documentation and examples
