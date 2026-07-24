# bloc_small

[![pub package](https://img.shields.io/pub/v/bloc_small.svg)](https://pub.dev/packages/bloc_small)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A lightweight, streamlined implementation of the BLoC pattern for Flutter state management. Built on [flutter_bloc](https://pub.dev/packages/flutter_bloc), `bloc_small` simplifies dependency injection, error handling, and async operations while maintaining full BLoC benefits.

## Features

- **Simplified BLoC & Cubit** — Easy-to-use state management via `MainBloc` and `MainCubit`
- **Dependency Injection** — Integrated GetIt setup with automatic `CommonBloc` registration
- **Error & Loading State Management** — Built-in `blocCatch`/`cubitCatch` and loading overlay helpers
- **Freezed Integration** — Full support for immutable states and events
- **ReactiveSubject API** — RxDart-powered stream transformations (`map`, `switchMap`, `debounceTime`, etc.)
- **auto_route Integration** — Optional type-safe navigation with deep linking
- **Stateless & Stateful Widgets** — `BaseBlocPage`/`BaseCubitPage` for both patterns

## Installation & Requirements

**Requirements:**
- Flutter >=3.38.0
- Dart >=3.9.2

Add to `pubspec.yaml`:

```yaml
dependencies:
  bloc_small:

dev_dependencies:
  build_runner:
  auto_route_generator:
  freezed:
  injectable_generator:
```

Then run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> Run this command whenever you modify Freezed or Injectable annotations.

## Core Concepts

| Class | Purpose |
|-------|---------|
| `MainBloc` | Foundation for event-driven state management |
| `MainCubit` | Simplified state management without events |
| `MainBlocEvent` | Base class for all BLoC events |
| `MainBlocState` | Base class for all states |
| `CommonBloc` | App-wide loading and common state |

**BLoC Example:**

```dart
@lazySingleton
class CountBloc extends MainBloc<CountEvent, CountState> {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrement);
  }

  Future<void> _onIncrement(Increment event, Emitter<CountState> emit) async {
    await blocCatch(actions: () async {
      await Future.delayed(Duration(seconds: 1));
      emit(state.copyWith(count: state.count + 1));
    });
  }
}
```

**Cubit Example:**

```dart
@lazySingleton
class CountCubit extends MainCubit<CountState> {
  CountCubit() : super(const CountState.initial());

  Future<void> increment() async {
    await cubitCatch(actions: () async {
      emit(state.copyWith(count: state.count + 1));
    });
  }
}
```

## Basic Usage

### 1. Set Up Dependency Injection

```dart
@InjectableInit()
void configureInjectionApp() {
  getIt.registerCore();  // Registers CommonBloc — required
  getIt.init();          // Registers your app dependencies
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjectionApp();
  runApp(MyApp());
}
```

> **Important:** `getIt.registerCore()` is required and registers `CommonBloc` as a lazy singleton. Omitting it will throw on first page load.

### 2. Define Events & States with Freezed

```dart
abstract class CountEvent extends MainBlocEvent {
  const CountEvent._();
}

@freezed
sealed class Increment extends CountEvent with _$Increment {
  const Increment._() : super._();
  const factory Increment() = _Increment;
}

@freezed
sealed class CountState extends MainBlocState with _$CountState {
  const CountState._();
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
```

### 3. Create a Page

```dart
class CounterPage extends StatefulWidget {
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends BaseBlocPageState<CounterPage, CountBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: BlocBuilder<CountBloc, CountState>(
        builder: (context, state) => Text('${state.count}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bloc.add(Increment()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Using Cubit

Cubit simplifies state management by using direct method calls instead of events:

```dart
@lazySingleton
class CountCubit extends MainCubit<CountState> {
  CountCubit() : super(const CountState.initial());

  void increment() => emit(state.copyWith(count: state.count + 1));
}
```

Use `BaseCubitPageState` and `BaseCubitPage` for page widgets. Call methods directly:

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () => cubit.increment(),
  child: const Icon(Icons.add),
)
```

| Aspect | BLoC | Cubit |
|--------|------|-------|
| Events | ✓ | ✗ |
| Complexity | Higher | Lower |
| Use Case | Complex logic | Simple updates |

## Bloc Ownership Rules

**The DI container owns every bloc and cubit. Widgets consume, never close them.**

1. **Register page state managers as singleton/lazy singleton** — `registerFactory` is not supported and will throw in debug builds. Factories create new instances per resolution, and pages never dispose what they didn't create.

   ```dart
   getIt.registerLazySingleton<CountBloc>(CountBloc.new);  // ✓
   // getIt.registerFactory<CountBloc>(CountBloc.new);     // ✗
   ```

2. **`CommonBloc` is app-wide** — Registered via `registerCore()`. Call `resetCore()` in tests/hot-restart.

3. **Do not annotate your router for codegen** — `registerAppRouter` registers the instance you provide. Annotating it with `@LazySingleton` would register it twice, causing `getIt.init()` to throw.

   ```dart
   @AutoRouterConfig()
   class AppRouter extends BaseAppRouter { }  // No @LazySingleton
   ```

## Using StatelessWidget

`BaseBlocPage` and `BaseCubitPage` receive the state manager in `buildPage`:

```dart
class CounterPage extends BaseBlocPage<CountBloc> {
  const CounterPage({super.key});

  @override
  Widget buildPage(BuildContext context, CountBloc bloc) {
    return Scaffold(
      body: BlocBuilder<CountBloc, CountState>(
        builder: (context, state) => Text('${state.count}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bloc.add(Increment()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## auto_route Integration

1. **Create Router:**

```dart
@AutoRouterConfig()
class AppRouter extends BaseAppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: SettingsRoute.page),
  ];
}
```

2. **Register & Configure:**

```dart
void configureInjectionApp() {
  getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: true);
  getIt.registerCore();
  getIt.init();
}

class MyApp extends StatelessWidget {
  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router.config(),
    );
  }
}
```

3. **Navigate:**

```dart
final navigator = getIt.getNavigator();
navigator?.push(const HomeRoute());
```

## Loading Overlay

Wrap your page content with `buildLoadingOverlay` to display a loading indicator:

```dart
Widget buildPage(BuildContext context) {
  return buildLoadingOverlay(
    child: Scaffold(...),
    loadingKey: 'myKey',  // Optional: for multiple loading states
  );
}
```

Control it from your bloc/cubit:

```dart
await blocCatch(actions: () async {
  showLoading();
  try {
    // Your async operation
  } finally {
    hideLoading();
  }
});
```

## Error Handling

Use `blocCatch` or `cubitCatch` to wrap async operations and handle errors automatically:

```dart
await blocCatch(
  actions: () async {
    // Your code here
  },
  onError: (error) {
    print('Error: $error');
  },
);
```

For standardized error handling, use `BaseErrorHandlerMixin`:

```dart
@lazySingleton
class CountBloc extends MainBloc<CountEvent, CountState> with BaseErrorHandlerMixin {
  // ...
  
  Future<void> _onIncrement(Increment event, Emitter<CountState> emit) async {
    await blocCatch(
      actions: () async { /* ... */ },
      onError: handleError,  // Uses mixin's error handler
    );
  }
}
```

The mixin provides automatic logging, error message generation, and loading state cleanup.

## ReactiveSubject

`ReactiveSubject<T>` wraps RxDart's `BehaviorSubject`/`PublishSubject` with a simplified API.

### API Reference

**Constructors & Core:**

| Method | Description |
|--------|-------------|
| `ReactiveSubject({T? initialValue})` | Creates with BehaviorSubject |
| `ReactiveSubject.broadcast()` | Creates with PublishSubject |
| `add(T value)` | Add new value |
| `dispose()` | Release resources |

**Transformation:**

| Method | Example |
|--------|---------|
| `map<R>()` | `subject.map((i) => i * 2)` |
| `where()` | `subject.where((i) => i > 0)` |
| `switchMap()` | `subject.switchMap((i) => api.fetch(i))` |
| `debounceTime()` | `subject.debounceTime(300.ms)` |
| `distinct()` | `subject.distinct()` |

**Example:**

```dart
final subject = ReactiveSubject<int>(initialValue: 0);
final stream = subject
    .map((i) => i * 2)
    .debounceTime(Duration(milliseconds: 300))
    .listen(print);
await subject.dispose();
```

## Contributing

Contributions welcome! Please open an issue or pull request on [GitHub](https://github.com/linhnguyen-gt/bloc_small).

## License

MIT License. See [LICENSE](LICENSE) file for details.
