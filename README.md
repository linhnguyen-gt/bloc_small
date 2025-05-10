# bloc_small

<div align="center">

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/your-repo)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

A lightweight and simplified BLoC (Business Logic Component) library for Flutter, built on top of the [flutter_bloc](https://pub.dev/packages/flutter_bloc) package. `bloc_small` simplifies state management, making it more intuitive while maintaining the core benefits of the BLoC pattern.

[Getting Started](#installation) • [Examples](https://github.com/linhnguyen-gt/bloc_small/tree/base_feature/example)

</div>

<summary>Table of Contents</summary>

1. [Features](#features)
2. [Installation](#installation)
3. [Core Concepts](#core-concepts)
4. [Basic Usage](#basic-usage)
5. [Using Cubit](#using-cubit-alternative-approach)
6. [Auto Route Integration](#if-you-want-to-use-auto-route-integration)
7. [Advanced Usage](#advanced-usage)
8. [Best Practices](#best-practices)
9. [API Reference](#api-reference)
10. [Contributing](#contributing)
11. [License](#license)

## Features

- Simplified BLoC pattern implementation using [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- Easy-to-use reactive programming with Dart streams
- Automatic resource management and disposal
- Integration with [GetIt](https://pub.dev/packages/get_it) for dependency injection
- Support for loading states and error handling
- Streamlined state updates and event handling
- Built-in support for asynchronous operations
- Seamless integration with [freezed](https://pub.dev/packages/freezed) for immutable state and event classes
- Enhanced `ReactiveSubject` with powerful stream transformation methods [rxdart](https://pub.dev/packages/rxdart)
- Optional integration with [auto_route](https://pub.dev/packages/auto_route) for type-safe navigation, including:
  - Platform-adaptive transitions
  - Deep linking support
  - Nested navigation
  - Compile-time route verification
  - Clean and consistent navigation API

## Installation

Add `bloc_small` to your `pubspec.yaml` file:

```yaml
dependencies:
  bloc_small:
  injectable:

dev_dependencies:
  injectable_generator:
  build_runner:
  freezed:
```

Then run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> **Note**: Remember to run the build runner command every time you make changes to files that use Freezed or Injectable annotations. This generates the necessary code for your BLoCs, events, and states.

## Core Concepts

| Class | Description | Base Class | Purpose |
|-------|-------------|------------|----------|
| `MainBloc` | Foundation for BLoC pattern implementation | `MainBlocDelegate` | Handles events and emits states |
| `MainCubit` | Simplified state management alternative | `MainCubitDelegate` | Direct state mutations without events |
| `MainBlocEvent` | Base class for all events | - | Triggers state changes in BLoCs |
| `MainBlocState` | Base class for all states | - | Represents application state |
| `CommonBloc` | Global functionality manager | - | Manages loading states and common features |

**BLoC Pattern:**

```dart
@injectable
class CounterBloc extends MainBloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState.initial()) {
    on<Increment>(_onIncrement);
  }
}
```

**Cubit Pattern:**

```dart
@injectable
class CounterCubit extends MainCubit<CounterState> {
  CounterCubit() : super(const CounterState.initial());

  void increment() => emit(state.copyWith(count: state.count + 1));
}
```

## Basic Usage

### 1. Set up Dependency Injection

Use GetIt and Injectable for dependency injection:

```dart
@InjectableInit()
void configureInjectionApp() {
  // Step 1: Register core dependencies from package bloc_small
  getIt.registerCore();

  // Step 2: Register your app dependencies
  getIt.init();
}
```

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjectionApp(); // Initialize both core and app dependencies
  runApp(MyApp());
}
```

> **Important**: The `RegisterModule` class with the `CommonBloc` singleton is essential. If you don't include this Dependency Injection setup, your app will encounter errors. The `CommonBloc` is used internally by `bloc_small` for managing common functionalities like loading states across your app.

Make sure to call `configureInjectionApp()` before running your app

### 2. Define your BLoC

```dart
@injectable
class CountBloc extends MainBloc<CountEvent, CountState> {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrementCounter);
    on<Decrement>(_onDecrementCounter);
  }

  Future<void> _onIncrementCounter(Increment event, Emitter<CountState> emit) async {
    await blocCatch(actions: () async {
      await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(count: state.count + 1));
    });
  }

  void _onDecrementCounter(Decrement event, Emitter<CountState> emit) {
    if (state.count > 0) emit(state.copyWith(count: state.count - 1));
  }
}
```

### 3. Define Events and States with Freezed

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
sealed class Decrement extends CountEvent with _$Decrement {
  const Decrement._() : super._();
  const factory Decrement() = _Decrement;
}
```

```dart
@freezed
sealed class CountState extends MainBlocState with _$CountState {
  const CountState._();
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
```

### 4. Create a StatefulWidget with BaseBlocPageState

```dart
class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  MyHomePageState createState() => _MyHomePageState();
}

class MyHomePageState extends BaseBlocPageState<MyHomePage, CountBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocBuilder<CountBloc, CountState>(
          builder: (context, state) {
            return Text(
              '${state.count}',
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => bloc.add(Increment()),
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => bloc.add(Decrement()),
            tooltip: 'decrement',
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

## Using Cubit (Alternative Approach)

If you prefer a simpler approach without events, you can use Cubit instead of BLoC:

### 1. Define your Cubit

```dart
@injectable
class CounterCubit extends MainCubit<CounterState> {
  CounterCubit() : super(const CounterState.initial());

  Future<void> increment() async {
    await cubitCatch(
      actions: () async {
        await Future.delayed(Duration(seconds: 1));
        emit(state.copyWith(count: state.count + 1));
      },
      keyLoading: 'increment',
    );
  }

  void decrement() {
    if (state.count > 0) {
      emit(state.copyWith(count: state.count - 1));
    }
  }
}
```

### 2. Define Cubit State with Freezed

```dart
@freezed
sealed class CountState extends MainBlocState with _$CountState {
  const CountState._();
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
```

### 3. Create a StatefulWidget with BaseCubitPageState

```dart
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends BaseCubitPageState<CounterPage, CountCubit> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      loadingKey: 'increment',
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter Example')),
        body: Center(
          child: BlocBuilder<CountCubit, CountState>(
            builder: (context, state) {
              return Text(
                '${state.count}',
                style: const TextStyle(fontSize: 48),
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => bloc.increment(),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () => bloc.decrement(),
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
```

<summary>Key differences when using Cubit</summary>

| Feature | BLoC                | Cubit |
|---------|---------------------|-------|
| Event Handling | Uses events         | Direct method calls |
| Base Class | `MainBloc`          | `MainCubit` |
| Widget State | `BaseBlocPageState` | `BaseCubitPageState` |
| Complexity | More boilerplate    | Simpler implementation |
| Use Case | Complex state logic | Simple state changes |

## Using StatelessWidget

bloc_small also supports StatelessWidget with similar functionality to StatefulWidget implementations.

### 1. Using BLoC with StatelessWidget

```dart
class MyHomePage extends BaseBlocPage<CountBloc> {
  const MyHomePage({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      context,
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter Example')),
        body: Center(
          child: BlocBuilder<CountBloc, CountState>(
            builder: (context, state) {
              return Text(
                '${state.count}',
                style: const TextStyle(fontSize: 48),
              );
            },
          ),
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

### 2. Using Cubit with StatelessWidget

```dart
class CounterPage extends BaseCubitPage<CountCubit> {
  const CounterPage({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      context,
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter Example')),
        body: Center(
          child: BlocBuilder<CountCubit, CountState>(
            builder: (context, state) {
              return Text(
                '${state.count}',
                style: const TextStyle(fontSize: 48),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => cubit.increment(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
```

### Key Features of StatelessWidget Implementation

| Feature | Description |
|---------|-------------|
| Base Classes | `BaseBlocPage` and `BaseCubitPage` |
| DI Support | Automatic dependency injection |
| Loading Management | Built-in loading overlay support |
| Navigation | Integrated navigation capabilities |
| State Management | Full BLoC/Cubit pattern support |

### When to Use StatelessWidget vs StatefulWidget

| Use Case | Widget Type |
|----------|------------|
| Simple UI without local state | StatelessWidget |
| Complex UI with local state | StatefulWidget |
| Performance-critical screens | StatelessWidget |
| Screens with lifecycle needs | StatefulWidget |

## If you want to use Auto Route Integration

1. Add auto_route to your dependencies:

```yaml
dev_dependencies:
  auto_route_generator:
```

2. Create your router:

```dart
@AutoRouterConfig()
@LazySingleton()
class AppRouter extends BaseAppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: SettingsRoute.page),
  ];
}
```

3. Register Router in Dependency Injection

Register your router during app initialization:

```dart
void configureInjectionApp() {
  // Register AppRouter (recommended)
  getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: true);

  // Register other dependencies
  getIt.registerCore();
  getIt.init();
}
```

4. Setup MaterialApp

Configure your MaterialApp to use auto_route:

```dart
class MyApp extends StatelessWidget {
  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router.config(),
      // ... other MaterialApp properties
    );
  }
}
```

5. Navigation

Use the provided `AppNavigator` for consistent navigation across your app:

```dart
class MyWidget extends StatelessWidget {
  final navigator = getIt.getNavigator();

  void _onNavigate() {
    navigator?.push(const HomeRoute());
  }
}
```

Use the bloc and cubit provided `AppNavigator`:

```dart
class _MyWidgetState extends BaseBlocPageState<MyWidget, MyWidgetBloc> {
  void _onNavigate() {
    navigator?.push(const HomeRoute());
  }
}
```

```dart
class _MyWidgetState extends BaseCubitPageState<MyWidget, MyWidgetCubit> {
  void _onNavigate() {
    navigator?.push(const HomeRoute());
  }
}
```

```dart
// Basic navigation
navigator?.push(const HomeRoute());

// Navigation with parameters
navigator?.push(UserRoute(userId: 123));
```

#### Best Practices

1. Always register AppRouter in your DI setup
2. Use the type-safe methods provided by AppNavigator
3. Handle potential initialization errors
4. Consider creating a navigation service class for complex apps

#### Features

- Type-safe routing
- Automatic route generation
- Platform-adaptive transitions
- Deep linking support
- Nested navigation
- Integration with dependency injection

#### Benefits

- Compile-time route verification
- Clean and consistent navigation API
- Reduced boilerplate code
- Better development experience
- Easy integration with bloc_small package

For more complex navigation scenarios and detailed documentation, refer to the [auto_route documentation](https://pub.dev/packages/auto_route).

Note: While you can use any navigation solution, this package is optimized to work with auto_route.
The integration between auto_route and this package provides

If you choose a different navigation solution, you'll need to implement your own navigation registration strategy.

## Advanced Usage

### Handling Loading States

`bloc_small` provides a convenient way to manage loading states and display loading indicators using the `CommonBloc` and the `buildLoadingOverlay` method.

#### Using buildLoadingOverlay

When using `BaseBlocPageState`, you can easily add a loading overlay to your entire page:

```dart
class MyHomePageState extends BaseBlocPageState<MyHomePage, CountBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('You have pushed the button this many times:'),
              BlocBuilder<CountBloc, CountState>(
                builder: (context, state) {
                  return Text('${state.count}');
                },
              )
            ],
          ),
        ),
        floatingActionButton: Wrap(
          spacing: 5,
          children: [
            FloatingActionButton(
              onPressed: () => bloc.add(Increment()),
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () => bloc.add(Decrement()),
              tooltip: 'decrement',
              child: Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
```

The `buildLoadingOverlay` method wraps your page content and automatically displays a loading indicator when the loading state is active.

#### Customizing the Loading Overlay

You can customize the loading overlay by providing a `loadingWidget` and specifying a `loadingKey`:

```dart
buildLoadingOverlay(
  child: YourPageContent(),
  loadingWidget: YourCustomLoadingWidget(),
  loadingKey:'customLoadingKey'
)
```

#### Activating the Loading State

To show or hide the loading overlay, use the `showLoading` and `hideLoading` methods in your BLoC:

```dart
class YourBloc extends MainBloc<YourEvent, YourState> {
  Future<void> someAsyncOperation() async {
    showLoading(); // or showLoading(key: 'customLoadingKey');
    try {
      // Perform async operation
    } finally {
      hideLoading(); // or hideLoading(key: 'customLoadingKey');
    }
  }
}
```

This approach provides a clean and consistent way to handle loading states across your application, with the flexibility to use global or component-specific loading indicators.

### Error Handling

Use the `blocCatch` method in your BLoC to handle errors:

```dart
await blocCatch(
  actions: () async {
    // Your async logic here
    throw Exception('Something went wrong');
  },
  onError: (error) {
    // Handle the error
    print('Error occurred: $error');
  }
);
```

### Error Handling with BlocErrorHandlerMixin

`bloc_small` provides a mixin for standardized error handling and logging:

```dart
@injectable
class CountBloc extends MainBloc<CountEvent, CountState> with BlocErrorHandlerMixin {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrement);
  }

  Future<void> _onIncrement(Increment event, Emitter<CountState> emit) async {
    await blocCatch(
      actions: () async {
        // Your async logic that might throw
        if (state.count > 5) {
          throw ValidationException('Count cannot exceed 5');
        }
        emit(state.copyWith(count: state.count + 1));
      },
      onError: handleError, // Uses the mixin's error handler
    );
  }
}
```

The mixin provides:

- Automatic error logging with stack traces
- Built-in support for common exceptions (NetworkException, ValidationException, TimeoutException)
- Automatic loading state cleanup
- Helper method for error messages

You can get error messages without state emission:

```dart
String message = getErrorMessage(error); // Returns user-friendly error message
```

For custom error handling, override the handleError method:

```dart
@override
Future<void> handleError(Object error, StackTrace stackTrace) async {
  // Always call super to maintain logging
  super.handleError(error, stackTrace);
  
  // Add your custom error handling here
  if (error is CustomException) {
    // Handle custom exception
  }
}
```

### Lifecycle Management

bloc_small provides lifecycle hooks to manage state and resources based on widget lifecycle events.

#### Using Lifecycle Hooks in BLoC

```dart
@injectable
class CounterBloc extends MainBloc<CounterEvent, CounterState> {
  Timer? _timer;

  CounterBloc() : super(const CounterState.initial()) {
    on<StartTimer>(_onStartTimer);
  }

  @override
  void onDependenciesChanged() {
    // Called when dependencies change (e.g., Theme, Locale)
    add(const CounterEvent.checkDependencies());
  }

  @override
  void onDeactivate() {
    // Called when widget is temporarily removed
    _timer?.cancel();
  }

  Future<void> _onStartTimer(StartTimer event, Emitter<CounterState> emit) async {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      add(const CounterEvent.increment());
    });
  }
}
```

#### Implementation in Widget

```dart
class CounterPage extends StatefulWidget {
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends BaseBlocPageState<CounterPage, CounterBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: Scaffold(
        body: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) => Text('Count: ${state.count}'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => bloc.add(const StartTimer()),
          child: Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
```

The lifecycle hooks are automatically managed by the base classes and provide:

- Automatic resource cleanup
- State synchronization with system changes
- Proper handling of widget lifecycle events
- Memory leak prevention

## ReactiveSubject

`ReactiveSubject<T>` is a wrapper around RxDart's BehaviorSubject/PublishSubject, providing a simplified API for reactive programming.

### API Reference

#### Core API

| Category | Method/Property | Description |
|----------|----------------|-------------|
| **Constructors** | `ReactiveSubject({T? initialValue})` | Creates new with BehaviorSubject |
| | `ReactiveSubject.broadcast()` | Creates new with PublishSubject |
| **Properties** | `value` | Current value |
| | `stream` | Underlying stream |
| | `isClosed` | Check if closed |
| | `isDisposed` | Check if disposed |
| **Core Methods** | `add(T value)` | Add new value |
| | `addError(Object error)` | Add error |
| | `dispose()` | Release resources |
| | `listen()` | Subscribe to stream |

#### Transformation Methods

| Method | Description | Example |
|--------|-------------|---------|
| `map<R>()` | Transform values | `subject.map((i) => i * 2)` |
| `where()` | Filter values | `subject.where((i) => i > 0)` |
| `switchMap()` | Switch streams | `subject.switchMap((i) => api.fetch(i))` |
| `distinct()` | Remove duplicates | `subject.distinct()` |
| `scan()` | Accumulate values | `subject.scan((sum, val) => sum + val)` |

#### Time Control

| Method | Description | Example |
|--------|-------------|---------|
| `debounceTime()` | Delay emissions | `subject.debounceTime(300.ms)` |
| `throttleTime()` | Rate limit | `subject.throttleTime(1.seconds)` |
| `buffer()` | Collect over time | `subject.buffer(timer)` |

#### Error Handling

| Method | Description | Example |
|--------|-------------|---------|
| `retry()` | Retry on error | `subject.retry(3)` |
| `onErrorResumeNext()` | Recover from error | `subject.onErrorResumeNext(backup)` |
| `debug()` | Debug stream | `subject.debug(tag: 'MyStream')` |

#### State Management

| Method | Description | Example |
|--------|-------------|---------|
| `share()` | Share subscription | `subject.share()` |
| `shareReplay()` | Cache and replay | `subject.shareReplay(maxSize: 2)` |
| `groupBy()` | Group values | `subject.groupBy((val) => val.type)` |

#### Static Methods

| Method | Description | Example |
|--------|-------------|---------|
| `combineLatest()` | Combine multiple subjects | `ReactiveSubject.combineLatest([s1, s2])` |
| `merge()` | Merge multiple subjects | `ReactiveSubject.merge([s1, s2])` |
| `fromFutureWithError()` | Create from Future | `ReactiveSubject.fromFutureWithError(future)` |

### Basic Usage Example

```dart
// Create and initialize
final subject = ReactiveSubject<int>(initialValue: 0);

// Transform and handle errors
final stream = subject
    .map((i) => i * 2)
    .debounceTime(Duration(milliseconds: 300))
    .retry(3)
    .debug(tag: 'MyStream');

// Subscribe
final subscription = stream.listen(
  print,
  onError: handleError,
);

// Cleanup
await subject.dispose();
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
