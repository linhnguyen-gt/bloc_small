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
  freezed:

dev_dependencies:
  injectable_generator:
  build_runner:
  freezed_annotation:
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
class Increment extends CountEvent with _$Increment {
  const factory Increment() = _Increment;
}

@freezed
class Decrement extends CountEvent with _$Decrement {
  const factory Decrement() = _Decrement;
}
```

```dart
@freezed
class CountState extends MainBlocState with $CountState {
  const factory CountState.initial({@Default(0) int count}) = Initial;
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
class CountState extends MainBlocState with $CountState {
  const factory CountState.initial({@Default(0) int count}) = Initial;
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
dependencies:
  auto_route:
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

## ReactiveSubject

### Using ReactiveSubject

ReactiveSubject is a powerful stream controller that combines the functionality of BehaviorSubject with additional reactive operators.

### Core Features

1. **Value Management**

```dart
// Create with initial value
final subject = ReactiveSubject<int>(initialValue: 0);

// Create broadcast subject
final broadcast = ReactiveSubject<int>.broadcast(initialValue: 0);

// Add values
subject.add(1);

// Get current value
print(subject.value);

// Check if closed
print(subject.isClosed);

// Dispose when done
subject.dispose();
```

### Stream Transformations

1. **map** - Transform each value

```dart
final celsius = ReactiveSubject<double>();
final fahrenheit = celsius.map((c) => c * 9/5 + 32);
```

2. **where** - Filter values

```dart
final numbers = ReactiveSubject<int>();
final evenNumbers = numbers.where((n) => n % 2 == 0);
```

3. **switchMap** - Switch to new stream

```dart
final searchQuery = ReactiveSubject<String>();
final results = searchQuery.switchMap((query) => 
  performSearch(query)); // Cancels previous search
```

4. **debounceTime** - Delay emissions

```dart
final input = ReactiveSubject<String>();
final debouncedInput = input.debounceTime(Duration(milliseconds: 300));
```

5. **throttleTime** - Rate limit emissions

```dart
final clicks = ReactiveSubject<void>();
final throttledClicks = clicks.throttleTime(Duration(seconds: 1));
```

6. **distinct** - Emit only when value changes

```dart
final values = ReactiveSubject<String>();
final distinctValues = values.distinct();
```

### Advanced Operations

1. **withLatestFrom** - Combine with another stream

```dart
final main = ReactiveSubject<int>();
final other = ReactiveSubject<String>();
final combined = main.withLatestFrom(other, 
  (int a, String b) => '$a-$b');
```

2. **startWith** - Begin with a value

```dart
final subject = ReactiveSubject<int>();
final withDefault = subject.startWith(0);
```

3. **scan** - Accumulate values

```dart
final prices = ReactiveSubject<double>();
final total = prices.scan<double>(
  0.0,
  (sum, price, _) => sum + price,
);
```

4. **doOnData/doOnError** - Side effects

```dart
final subject = ReactiveSubject<int>();
final withLogging = subject
  .doOnData((value) => print('Emitted: $value'))
  .doOnError((error, _) => print('Error: $error'));
```

### Static Operators

1. **combineLatest** - Combine multiple subjects

```dart
final subject1 = ReactiveSubject<int>();
final subject2 = ReactiveSubject<String>();
final combined = ReactiveSubject.combineLatest([subject1, subject2]);
```

2. **merge** - Merge multiple subjects

```dart
final subject1 = ReactiveSubject<int>();
final subject2 = ReactiveSubject<int>();
final merged = ReactiveSubject.merge([subject1, subject2]);
```

### Practical Example in BLoC

Here's how you might use `ReactiveSubject` within a `BLoC` to manage state:

```dart
class SearchBloc extends MainBloc<SearchEvent, SearchState> {
  final ReactiveSubject<String> _searchQuery = ReactiveSubject<String>();
  late final ReactiveSubject<List<String>> _searchResults;

  SearchBloc() : super(const SearchState.initial()) {
    _searchResults = _searchQuery
        .debounceTime(Duration(milliseconds: 100))
        .doOnData((query) {
      showLoading(key: 'search');
      })
        .switchMap((query) => _performSearch(query))
        .doOnData((query) => hideLoading(key: 'search'));

    _searchResults.stream.listen((results) {
      add(UpdateResults(results));
    });

    on<UpdateQuery>(_onUpdateQuery);
    on<UpdateResults>(_onUpdateResults);
    on<SearchError>(_onSearchError);
  }

  Future<void> _onUpdateQuery(
      UpdateQuery event, Emitter<SearchState> emit) async {
    await blocCatch(
        keyLoading: 'search',
        actions: () async {
          await Future.delayed(Duration(seconds: 2));
          _searchQuery.add(event.query);
        });
  }

  void _onUpdateResults(UpdateResults event, Emitter<SearchState> emit) {
    emit(SearchState.loaded(event.results));
  }

  void _onSearchError(SearchError event, Emitter<SearchState> emit) {
    emit(SearchState.error(event.message));
  }

  Stream<List<String>> _performSearch(String query) {
    final resultSubject = ReactiveSubject<List<String>>();
    Future.delayed(Duration(seconds: 1)).then((_) {
      if (query.isEmpty) {
        resultSubject.add([]);
      } else {
        resultSubject.add(['Result 1 for "$query"', 'Result 2 for "$query"']);
      }
    }).catchError((error) {
      add(SearchError(error.toString()));
    });

    return resultSubject.stream;
  }

  @override
  Future<void> close() {
    _searchQuery.dispose();
    _searchResults.dispose();
    return super.close();
  }
}
```

### Error Handling

```dart
// Add error
subject.addError('Something went wrong');

// Handle errors in stream
subject.stream.listen(
  (data) => print('Data: $data'),
  onError: (error) => print('Error: $error'),
);

// Using fromFutureWithError
final subject = ReactiveSubject.fromFutureWithError(
  Future.delayed(Duration(seconds: 1)),
  onError: (error) => print('Error: $error'),
  onFinally: () => print('Completed'),
  timeout: Duration(seconds: 5),
);
```

### Best Practices

1. Always dispose subjects when no longer needed
2. Use broadcast subjects for multiple listeners
3. Consider memory implications with large datasets
4. Handle errors appropriately
5. Use meaningful variable names
6. Document complex transformations
7. Consider using timeouts for async operations

## Best Practices

### 1. State Management

- Keep states immutable using Freezed
- Use meaningful state classes
- Avoid storing complex objects in state

### 2. Event Handling

- Keep events simple and focused
- Use meaningful event names
- Document complex event flows

### 3. Error Handling

- Always use blocCatch for async operations
- Implement proper error recovery
- Log errors appropriately

### 4. Testing

- Test BLoCs in isolation
- Mock dependencies
- Test error scenarios
- Verify state transitions

### 5. Architecture

- Follow single responsibility principle
- Keep BLoCs focused and small
- Use dependency injection
- Implement proper separation of concerns

## API Reference

### MainBloc

- `MainBloc(initialState)`: Constructor for creating a new BLoC.
- `blocCatch({required Future<void> Function() actions, Function(dynamic)? onError})`: Wrapper for handling errors in async operations.
- `showLoading({String key = 'global'})`: Shows a loading indicator.
- `hideLoading({String key = 'global'})`: Hides the loading indicator.

### MainBlocState

Base class for all states in your BLoCs.

### MainBlocEvent

Base class for all events in your BLoCs.

### CommonBloc

- `add(SetComponentLoading)`: Set loading state for a component.
- `state.isLoading(String key)`: Check if a component is in loading state.

### ReactiveSubject

`ReactiveSubject<T>` is a wrapper around RxDart's `BehaviorSubject` or `PublishSubject`, providing a simpler API for reactive programming in Dart.

# Constructors

- `ReactiveSubject({T? initialValue})`: Creates a new `ReactiveSubject` (wraps `BehaviorSubject`).
- `ReactiveSubject.broadcast({T? initialValue})`: Creates a new broadcast `ReactiveSubject` (wraps `PublishSubject`).

# Properties

- `T value`: Gets the current value of the subject.
- `Stream<T> stream`: Gets the stream of values emitted by the subject.
- `Sink<T> sink`: Gets the sink for adding values to the subject.
- `bool isClosed`: Indicates whether the subject is closed.

# Methods

- `void add(T value)`: Adds a new value to the subject.
- `void addError(Object error, [StackTrace? stackTrace])`: Adds an error to the subject.
- `void dispose()`: Disposes of the subject.

# Transformation Methods

- `ReactiveSubject<R> map<R>(R Function(T event) mapper)`: Transforms each item emitted by applying a function.
- `ReactiveSubject<T> where(bool Function(T event) test)`: Filters items based on a predicate.
- `ReactiveSubject<R> switchMap<R>(Stream<R> Function(T event) mapper)`: Switches to a new stream when a new item is emitted.
- `ReactiveSubject<T> debounceTime(Duration duration)`: Emits items only after a specified duration has passed without another emission.
- `ReactiveSubject<T> throttleTime(Duration duration)`: Emits the first item in specified intervals.
- `ReactiveSubject<T> distinct([bool Function(T previous, T next)? equals])`: Emits items that are distinct from their predecessors.
- `ReactiveSubject<T> startWith(T startValue)`: Prepends a given value to the subject.
- `ReactiveSubject<R> scan<R>(R initialValue, R Function(R accumulated, T current, int index) accumulator)`: Accumulates items using a function.
- `ReactiveSubject<R> withLatestFrom<S, R>(ReactiveSubject<S> other, R Function(T event, S latestFromOther) combiner)`: Combines items with the latest from another subject.
- `ReactiveSubject<T> doOnData(void Function(T event) onData)`: Performs a side-effect action for each data event emitted.
- `ReactiveSubject<T> doOnError(void Function(Object error, StackTrace stackTrace) onError)`: Performs a side-effect action for each error event emitted.

# Static Methods

- `static ReactiveSubject<List<T>> combineLatest<T>(List<ReactiveSubject<T>> subjects)`: Combines the latest values of multiple subjects.
- `static ReactiveSubject<T> merge<T>(List<ReactiveSubject<T>> subjects)`: Merges multiple subjects into one.

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to:

- Update tests as appropriate
- Update documentation
- Follow the existing coding style
- Add examples for new features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
