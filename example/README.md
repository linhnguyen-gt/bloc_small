# bloc_small Example Application

A comprehensive example application demonstrating all features of the `bloc_small` package.

## Overview

This example app showcases:
- **BLoC Pattern** - Event-driven state management
- **Cubit Pattern** - Simplified state management
- **Navigation** - Type-safe routing with `auto_route`
- **Dependency Injection** - GetIt and Injectable setup
- **Loading States** - Global and component-specific loading indicators
- **Error Handling** - Standardized error management
- **ReactiveSubject** - Advanced reactive programming examples

## Getting Started

### Prerequisites

- Flutter SDK ^3.7.2
- Dart SDK ^3.7.2

### Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   This generates:
   - Freezed classes (states, events)
   - Injectable dependency injection code
   - Auto route navigation code

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
example/lib/
├── main.dart                    # App entry point
├── home.dart                    # BLoC counter example
├── search_page.dart             # Search with BLoC example
├── count_page_cubit.dart        # Cubit counter example
├── bloc/                        # BLoC implementations
│   ├── count/                   # Counter BLoC
│   │   ├── count_bloc.dart
│   │   ├── count_event.dart
│   │   └── count_state.dart
│   └── search/                  # Search BLoC
│       ├── search_bloc.dart
│       ├── search_event.dart
│       └── search_state.dart
├── cubit/                       # Cubit implementations
│   └── cubit/
│       ├── count_cubit.dart
│       └── count_state.dart
├── di/                          # Dependency injection
│   ├── di.dart                  # DI configuration
│   └── di.config.dart           # Generated DI code
├── navigation/                  # Navigation setup
│   ├── app_router.dart          # Router configuration
│   └── app_router.gr.dart       # Generated routes
├── drawer/                      # Navigation drawer
│   ├── menu_drawer.dart
│   └── menu_item.dart
└── reactive_subject/            # ReactiveSubject examples
    ├── reacttive_subject_screen.dart
    ├── debounced_search.dart
    ├── combined_form_validation.dart
    ├── api_retry_example.dart
    ├── distinct_api_calls.dart
    ├── rate_limited_button.dart
    ├── shopping_cart.dart
    ├── stock_price.dart
    ├── temperature_converter.dart
    └── ... (more examples)
```

## Examples

### 1. BLoC Pattern (Counter)

**Location:** `lib/home.dart` and `lib/bloc/count/`

Demonstrates:
- Creating a BLoC with `MainBloc`
- Defining events and states with Freezed
- Using `BaseBlocPageState` for widget state
- Loading overlay management
- Error handling with `BlocErrorHandlerMixin`

**Key Features:**
- Increment/Decrement counter
- Async operations with loading states
- Error handling (count limit validation)

### 2. Cubit Pattern (Counter)

**Location:** `lib/count_page_cubit.dart` and `lib/cubit/cubit/`

Demonstrates:
- Creating a Cubit with `MainCubit`
- Direct state mutations
- Using `BaseCubitPageState` for widget state
- Component-specific loading keys

**Key Features:**
- Simpler API than BLoC
- Same functionality with less boilerplate

### 3. Search with BLoC

**Location:** `lib/search_page.dart` and `lib/bloc/search/`

Demonstrates:
- Complex state management with multiple states
- Pattern matching with Freezed sealed classes
- Component-specific loading states
- Real-time search functionality

**Key Features:**
- Debounced search input
- Loading states during search
- Error handling
- Empty state handling

### 4. Navigation

**Location:** `lib/navigation/app_router.dart`

Demonstrates:
- Setting up `auto_route` with `BaseAppRouter`
- Type-safe navigation
- Route configuration
- Deep linking support

**Key Features:**
- Platform-adaptive transitions
- Type-safe route parameters
- Navigation drawer integration

### 5. Dependency Injection

**Location:** `lib/di/di.dart`

Demonstrates:
- Setting up GetIt and Injectable
- Registering core dependencies
- Registering app router
- Auto-generating DI code

**Key Setup:**
```dart
@injectableInit
void configureInjectionApp() {
  // Register router (optional)
  getIt.registerAppRouter<AppRouter>(AppRouter());
  
  // Register core dependencies
  getIt.registerCore();
  
  // Initialize injectable
  getIt.init();
}
```

### 6. ReactiveSubject Examples

**Location:** `lib/reactive_subject/`

Comprehensive examples demonstrating `ReactiveSubject` capabilities:

- **Debounced Search** - Search with debounce delay
- **Combined Form Validation** - Multiple form fields validation
- **API Retry** - Retry failed API calls
- **Distinct API Calls** - Prevent duplicate API calls
- **Rate Limited Button** - Throttle button clicks
- **Shopping Cart** - Shopping cart state management
- **Stock Price** - Real-time price updates
- **Temperature Converter** - Bidirectional conversion
- **Email Filter** - Filter emails with multiple criteria
- **Notification Merger** - Merge multiple notification streams
- **Action with Latest Context** - Combine latest values
- **Default Settings** - Settings management

## Key Concepts Demonstrated

### Loading States

**Global Loading:**
```dart
buildLoadingOverlay(
  child: YourWidget(),
)
```

**Component-Specific Loading:**
```dart
buildLoadingOverlay(
  loadingKey: 'search',
  child: YourWidget(),
)
```

### Error Handling

**With Error Handler Mixin:**
```dart
class MyBloc extends MainBloc<MyEvent, MyState> 
    with BlocErrorHandlerMixin {
  Future<void> _onEvent(Event event, Emitter<State> emit) async {
    await blocCatch(
      actions: () async {
        // Your logic
      },
      onError: handleError,
    );
  }
}
```

### Navigation

**Using AppNavigator:**
```dart
class MyPageState extends BaseBlocPageState<MyPage, MyBloc> {
  void navigate() {
    navigator?.push(const SearchRoute());
  }
}
```

## Running Tests

```bash
flutter test
```

## Code Generation

Whenever you modify:
- Freezed classes (states, events)
- Injectable classes
- Auto route definitions

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or watch for changes:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Learn More

- [Main Package Documentation](../README.md)
- [Project Overview](../docs/project-overview-pdr.md)
- [Codebase Summary](../docs/codebase-summary.md)
- [System Architecture](../docs/system-architecture.md)
- [Code Standards](../docs/code-standards.md)
