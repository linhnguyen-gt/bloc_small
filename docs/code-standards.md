# Code Standards & Structure

## File Organization

### Directory Structure

```
lib/
├── bloc_small.dart              # Main export file
├── core/                        # Core functionality (internal)
│   ├── constants/               # Constants and enums
│   ├── di/                      # Dependency injection
│   ├── error/                   # Error handling
│   ├── extensions/              # Internal extensions
│   └── utils/                   # Utility classes
├── extensions/                  # Public extensions
├── navigation/                  # Navigation abstraction
└── presentation/                 # Presentation layer
    ├── base/                    # Base classes
    ├── bloc/                    # BLoC implementations
    ├── cubit/                   # Cubit implementations
    └── widgets/                 # Reusable widgets
```

### File Naming Conventions

- **Files**: Use `snake_case` (e.g., `base_bloc_page_state.dart`)
- **Classes**: Use `PascalCase` (e.g., `BaseBlocPageState`)
- **Mixins**: Use `PascalCase` with descriptive names (e.g., `BaseDelegate`)
- **Extensions**: Use `PascalCase` with descriptive names (e.g., `AppNavigatorExtension`)

## Code Style

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide:

1. **Use `lowerCamelCase` for variables, parameters, and named parameters**
   ```dart
   final loadingKey = LoadingKey.global;
   void showLoading({String? key}) {}
   ```

2. **Use `UpperCamelCase` for types and classes**
   ```dart
   class BaseBlocPageState<T, B> {}
   ```

3. **Use `lowercase_with_underscores` for library names and file names**
   ```dart
   library bloc_small;
   // file: base_bloc_page_state.dart
   ```

4. **Use `SCREAMING_CAPS` for constants**
   ```dart
   static const String LOADING_KEY = 'global';
   ```

### Documentation Standards

#### Class Documentation
```dart
/// A base class for all StatefulWidget states in the application.
///
/// This class extends [BasePageDelegate] and provides a foundation for creating
/// state classes that are associated with a specific Bloc.
///
/// Type Parameters:
/// - [T]: The type of the StatefulWidget this state is associated with.
/// - [B]: The type of Bloc this state will use. Must extend [MainBloc].
///
/// Usage:
/// ```dart
/// class MyHomePageState extends BaseBlocPageState<MyHomePage, MyBloc> {
///   // ...
/// }
/// ```
```

#### Method Documentation
```dart
/// Shows the loading overlay for a specific key.
///
/// [key] is a unique identifier for the loading state. If not provided,
/// it defaults to [LoadingKey.global].
///
/// Usage:
/// ```dart
/// showLoading(key: 'myOperation');
/// ```
void showLoading({String? key = LoadingKey.global}) {}
```

### Code Organization Within Files

1. **Imports** (in order):
   - Dart SDK imports
   - Flutter imports
   - Package imports
   - Relative imports

2. **Class Structure**:
   - Class documentation
   - Class declaration
   - Constants
   - Fields
   - Constructors
   - Getters/Setters
   - Methods (public first, then private)
   - Lifecycle methods

Example:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Class documentation
class MyClass {
  // Constants
  static const String constant = 'value';
  
  // Fields
  final String field;
  
  // Constructors
  MyClass(this.field);
  
  // Getters/Setters
  String get value => field;
  
  // Public methods
  void publicMethod() {}
  
  // Private methods
  void _privateMethod() {}
}
```

## Design Patterns

### 1. Base Class Pattern

All BLoCs extend `MainBloc`, all Cubits extend `MainCubit`:
```dart
@injectable
class MyBloc extends MainBloc<MyEvent, MyState> {
  MyBloc() : super(const MyState.initial()) {
    on<MyEvent>(_onMyEvent);
  }
}
```

### 2. Mixin Pattern

Shared functionality provided via mixins:
```dart
class MyBloc extends MainBloc<MyEvent, MyState> 
    with BlocErrorHandlerMixin {
  // ...
}
```

### 3. Factory Pattern

Use factory constructors for complex initialization:
```dart
ReactiveSubject.broadcast({T? initialValue})
  : _subject = PublishSubject<T>() {
  // ...
}
```

### 4. Dependency Injection

Use `@injectable` annotation for automatic DI:
```dart
@injectable
class MyBloc extends MainBloc<MyEvent, MyState> {
  // ...
}
```

## Error Handling

### Standard Error Handling

Use `blocCatch` or `cubitCatch` for async operations:
```dart
Future<void> _onEvent(Event event, Emitter<State> emit) async {
  await blocCatch(
    actions: () async {
      // Your async logic
    },
    onError: handleError,
  );
}
```

### Custom Exceptions

Use provided exception types:
```dart
throw NetworkException('Failed to fetch data');
throw ValidationException('Invalid input');
throw TimeoutException('Request timed out');
```

## State Management

### State Classes

Use Freezed for immutable states:
```dart
@freezed
sealed class MyState extends MainBlocState with _$MyState {
  const MyState._();
  const factory MyState.initial() = _Initial;
  const factory MyState.loaded(String data) = _Loaded;
}
```

### Event Classes

Use Freezed for events:
```dart
@freezed
sealed class MyEvent extends MainBlocEvent with _$MyEvent {
  const MyEvent._();
  const factory MyEvent.load() = _Load;
}
```

## Testing Standards

### Test File Naming

- Test files: `*_test.dart`
- Test classes: `*Test`
- Test methods: `test_*` or `should_*`

### Test Structure

```dart
void main() {
  group('MyBloc', () {
    late MyBloc bloc;
    
    setUp(() {
      bloc = MyBloc();
    });
    
    tearDown(() {
      bloc.close();
    });
    
    test('should emit initial state', () {
      expect(bloc.state, const MyState.initial());
    });
  });
}
```

## Best Practices

### 1. Keep Files Under 200 Lines

Split large files into smaller, focused modules.

### 2. Use Type Safety

- Prefer explicit types over `var`
- Use generic types where appropriate
- Leverage Dart's type system

### 3. Handle Null Safety

- Use nullable types (`?`) when values can be null
- Use null-aware operators (`?.`, `??`)
- Provide default values where appropriate

### 4. Resource Management

- Always dispose of resources (streams, controllers)
- Use `try-finally` for cleanup
- Implement proper lifecycle hooks

### 5. Avoid Code Duplication

- Extract common logic into mixins or base classes
- Use extensions for utility methods
- Create reusable widgets/components

### 6. Documentation

- Document public APIs
- Include usage examples
- Explain complex logic
- Keep documentation up-to-date

## Linting Rules

The project uses `flutter_lints: ^6.0.0` with standard Flutter linting rules. Key rules:

- Prefer `const` constructors
- Avoid `print` statements (use `developer.log`)
- Prefer single quotes for strings
- Use trailing commas in multi-line structures
- Prefer `final` over `var`

## Code Review Checklist

- [ ] Code follows style guide
- [ ] Documentation is complete
- [ ] Tests are written and passing
- [ ] No hardcoded values
- [ ] Error handling is appropriate
- [ ] Resource cleanup is implemented
- [ ] Type safety is maintained
- [ ] No code duplication
- [ ] Performance considerations addressed
