# Codebase Summary

## Project Structure

```
bloc_small/
├── lib/
│   ├── bloc_small.dart          # Main export file
│   ├── core/                    # Core functionality
│   │   ├── constants/           # Constants (loading keys)
│   │   ├── di/                   # Dependency injection
│   │   ├── error/                # Error handling
│   │   ├── extensions/          # Extension methods
│   │   └── utils/                # Utilities (ReactiveSubject)
│   ├── extensions/              # Public extensions
│   ├── navigation/               # Navigation abstraction
│   └── presentation/             # Presentation layer
│       ├── base/                 # Base classes for pages
│       ├── bloc/                 # BLoC implementations
│       ├── cubit/                # Cubit implementations
│       └── widgets/              # Reusable widgets
├── test/                        # Test files
├── example/                     # Example application
└── docs/                        # Documentation
```

## Core Components

### 1. Base Classes (`lib/presentation/base/`)

#### `BaseDelegate<S>`
- Mixin providing shared functionality for Bloc and Cubit
- Loading state management (`showLoading`, `hideLoading`)
- Error handling (`catchError`)
- Navigation support
- Common bloc integration

#### `BaseBlocDelegate<E, S>`
- Extends `Bloc<E, S>` with `BaseDelegate`
- Provides `blocCatch` method for error handling
- Event handling with safety checks
- State reset functionality

#### `MainBloc<E, S>`
- Abstract base class for all BLoCs
- Extends `BaseBlocDelegate`
- Lifecycle hooks (`onDependenciesChanged`, `onDeactivate`)

#### `MainCubit<S>`
- Abstract base class for all Cubits
- Extends `Cubit<S>` with `BaseDelegate`
- Provides `cubitCatch` method

### 2. Page Base Classes

#### `BaseBlocPageState<T, B>`
- For StatefulWidget with BLoC
- Automatic dependency injection
- Loading overlay management
- Lifecycle integration

#### `BaseCubitPageState<T, C>`
- For StatefulWidget with Cubit
- Similar to `BaseBlocPageState` but for Cubit

#### `BaseBlocPage<B>`
- For StatelessWidget with BLoC
- Stateless version of `BaseBlocPageState`

#### `BaseCubitPage<C>`
- For StatelessWidget with Cubit
- Stateless version of `BaseCubitPageState`

### 3. State Management (`lib/presentation/bloc/`)

#### `CommonBloc`
- Global state manager for loading states
- Manages component-specific loading keys
- Singleton instance via DI

#### `MainBlocEvent`
- Base class for all events
- Used with Freezed for pattern matching

#### `MainBlocState`
- Base class for all states
- Used with Freezed for immutable states

### 4. Error Handling (`lib/core/error/`)

#### Exception Types
- `NetworkException` - Network-related errors
- `ValidationException` - Validation errors
- `TimeoutException` - Timeout errors

#### Error Handlers
- `BlocErrorHandlerMixin` - Mixin for BLoC error handling
- `CubitErrorHandlerMixin` - Mixin for Cubit error handling
- Standardized error logging and management

### 5. Navigation (`lib/navigation/`)

#### `AppNavigator`
- Wrapper around `auto_route` router
- Type-safe navigation methods
- Optional navigation logging
- Error handling for missing router

#### `INavigator`
- Interface for navigation abstraction
- Allows different navigation implementations

#### `BaseAppRouter`
- Base class for app routers
- Integration point for `auto_route`

### 6. Dependency Injection (`lib/core/di/`)

#### `CoreModule`
- Injectable module for core dependencies
- Registers `CommonBloc` as singleton

#### `CoreInjection` Extension
- `registerCore()` - Registers core dependencies
- `registerAppRouter<T>()` - Registers router and navigator

### 7. Reactive Programming (`lib/core/utils/`)

#### `ReactiveSubject<T>`
- Wrapper around RxDart's `BehaviorSubject`/`PublishSubject`
- Simplified API for reactive programming
- Stream transformation methods:
  - `map`, `where`, `switchMap`
  - `debounceTime`, `throttleTime`
  - `distinct`, `scan`
  - `retry`, `onErrorResumeNext`
  - `share`, `shareReplay`
  - `buffer`, `groupBy`
  - And many more...

### 8. Extensions (`lib/extensions/` & `lib/core/extensions/`)

#### `AppNavigatorExtension`
- Extension on `GetIt` for easy navigator access
- `getNavigator()` method

#### `BlocContextExtension`
- Extension on `BuildContext` for BLoC access
- `getBloc<T>()` and `readBloc<T>()` methods

## Key Design Patterns

### 1. Template Method Pattern
- Base classes define structure, subclasses implement specifics
- `MainBloc` and `MainCubit` provide template for state management

### 2. Mixin Pattern
- `BaseDelegate` provides shared functionality via mixin
- `BlocErrorHandlerMixin` and `CubitErrorHandlerMixin` for error handling

### 3. Dependency Injection
- GetIt for service location
- Injectable for code generation
- Singleton pattern for `CommonBloc`

### 4. Observer Pattern
- BLoC pattern inherently uses observer pattern
- `ReactiveSubject` implements observer pattern for streams

### 5. Strategy Pattern
- Navigation abstraction allows different implementations
- Error handling strategies via mixins

## File Organization Principles

1. **Separation of Concerns**
   - Core functionality separated from presentation
   - Error handling isolated in dedicated module
   - Navigation abstracted from implementation

2. **Single Responsibility**
   - Each class has a single, well-defined purpose
   - Base classes focus on one pattern (BLoC or Cubit)

3. **Dependency Inversion**
   - Dependencies injected, not created
   - Abstractions (interfaces) used where possible

4. **DRY (Don't Repeat Yourself)**
   - Common functionality in `BaseDelegate` mixin
   - Shared extensions for common operations

## Testing Structure

```
test/
├── core/
│   ├── error/                   # Error handling tests
│   └── utils/                   # ReactiveSubject tests
└── presentation/
    ├── bloc/                    # BLoC tests
    └── widgets/                 # Widget tests
```

## Example Application

The `example/` directory contains a complete Flutter application demonstrating all features of `bloc_small`. See [example/README.md](../example/README.md) for detailed documentation.

### Example Structure

```
example/lib/
├── main.dart                    # App entry point with DI setup
├── home.dart                    # BLoC counter example
├── search_page.dart             # Search with BLoC example
├── count_page_cubit.dart        # Cubit counter example
├── bloc/                        # BLoC implementations
│   ├── count/                   # Counter BLoC with error handling
│   └── search/                  # Search BLoC with async operations
├── cubit/                       # Cubit implementations
│   └── cubit/                   # Counter Cubit
├── di/                          # Dependency injection setup
├── navigation/                  # Auto route navigation
├── drawer/                      # Navigation drawer
└── reactive_subject/            # 12+ ReactiveSubject examples
```

### Examples Demonstrate

- **BLoC Pattern**: Event-driven state management with `MainBloc`
- **Cubit Pattern**: Simplified state management with `MainCubit`
- **Loading States**: Global and component-specific loading indicators
- **Error Handling**: Standardized error management with mixins
- **Navigation**: Type-safe routing with `auto_route` and `BaseAppRouter`
- **Dependency Injection**: GetIt and Injectable setup
- **ReactiveSubject**: Advanced reactive programming patterns:
  - Debounced search
  - Form validation
  - API retry logic
  - Rate limiting
  - Shopping cart state
  - Real-time updates
  - And more...

## Export Strategy

All public APIs are exported through `lib/bloc_small.dart`:
- Core functionality
- Presentation layer classes
- Navigation components
- Extensions
- Third-party package re-exports (for convenience)
