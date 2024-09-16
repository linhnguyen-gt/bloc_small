# bloc_small

A lightweight and simplified BLoC (Business Logic Component) library for Flutter, built on top of the `flutter_bloc`
package. This library is designed to make state management easier and more intuitive, while leveraging the power and
flexibility of `flutter_bloc`. `bloc_small` aims to simplify the BLoC pattern implementation, maintaining its core
benefits of separating business logic from presentation code, and providing additional utilities and abstractions for
common use cases.

## Table of Contents

1. [Features](#features)
2. [Installation](#installation)
3. [Core Concepts](#core-concepts)
4. [Basic Usage](#basic-usage)
5. [Advanced Usage](#advanced-usage)
6. [Best Practices](#best-practices)
7. [API Reference](#api-reference)
8. [Contributing](#contributing)
9. [License](#license)

## Features

- Simplified BLoC pattern implementation using `flutter_bloc`
- Easy-to-use reactive programming with Dart streams
- Automatic resource management and disposal
- Integration with `GetIt` for dependency injection
- Support for loading states and error handling
- Streamlined state updates and event handling
- Built-in support for asynchronous operations
- Seamless integration with `Freezed` for immutable state and event classes
- Enhanced `ReactiveSubject` with powerful stream transformation methods

## Installation

Add `bloc_small` to your `pubspec.yaml` file:

```yaml
dependencies:
  bloc_small:
  flutter_bloc:
  injectable:
  freezed:
  get_it:

dev_dependencies:
  injectable_generator:
  build_runner:
  freezed_annotation:
```

Then run:

```
After adding or modifying any code that uses Freezed or Injectable, run the build runner:
```
flutter pub run build_runner build --delete-conflicting-outputs

> **Note**: Remember to run the build runner command every time you make changes to files that use Freezed or Injectable annotations. This generates the necessary code for your BLoCs, events, and states.


## Core Concepts

### MainBloc

The `MainBloc` class is the foundation of your BLoCs. It extends `MainBlocDelegate` and provides a structure for
handling events and emitting states.

### MainBlocEvent

All events in your BLoCs should extend `MainBlocEvent`. These events trigger state changes in your BLoC.

### MainBlocState

States in your BLoCs should extend `MainBlocState`. These represent the current state of your application or a specific
feature.

### CommonBloc

The `CommonBloc` is used for managing common functionalities across your app, such as loading states.

## Basic Usage

### 1. Define your BLoC

Create a class that extends `MainBloc`:

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

### 2. Define Events and States with Freezed

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

### 3. Set up Dependency Injection

Use GetIt and Injectable for dependency injection:

```dart

final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjectionApp() => getIt.init();

@module
abstract class RegisterModule {
  @injectable
  CommonBloc get commonBloc => CommonBloc();
}
```

> **Important**: The `RegisterModule` class with the `CommonBloc` singleton is essential. If you don't include this
> Dependency Injection setup, your app will encounter errors. The `CommonBloc` is used internally by `bloc_small` for
> managing common functionalities like loading states across your app.

Make sure to call `configureInjectionApp()` before running your app:

### 4. Create a StatefulWidget with BasePageState

```dart
class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  MyHomePageState createState() => _MyHomePageState(getIt);
}

class MyHomePageState extends BasePageState<MyHomePage, CountBloc> {
  MyHomePageState(GetIt getIt) : super(getIt);

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

### 5. Initialize the App

In your `main.dart` file:

```dart
void main() {
  configureInjectionApp();
  runApp(MyApp());
}
```

## Advanced Usage

### Handling Loading States

`bloc_small` provides a convenient way to manage loading states and display loading indicators using the `CommonBloc`
and the `buildLoadingOverlay` method.

#### Using buildLoadingOverlay

When using `BasePageState`, you can easily add a loading overlay to your entire page:

```dart
class MyHomePageState extends BasePageState<MyHomePage, CountBloc> {
  MyHomePageState(GetIt getIt) : super(getIt);

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

The `buildLoadingOverlay` method wraps your page content and automatically displays a loading indicator when the loading
state is active.

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

This approach provides a clean and consistent way to handle loading states across your application, with the flexibility
to use global or component-specific loading indicators.

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


### Using ReactiveSubject
> Note: ReactiveSubject uses RxDart internally.

`ReactiveSubject` provides a powerful and flexible way to work with streams in your application. It wraps RxDart's `BehaviorSubject` or `PublishSubject`, offering a simplified API with additional stream transformation methods. Here's how to use it:
1. Creating a ReactiveSubject:

- For a single-subscription subject with an initial value
```dart
final counter = ReactiveSubject<int>(initialValue: 0);
```
- For a broadcast subject (multiple listeners)
```dart
final broadcastCounter = ReactiveSubject<int>.broadcast(initialValue: 0);
```

2. Adding values:

```dart
counter.add(1);
counter.add(2);
```

3. Getting the current value:

```dart
print(counter.value); // Prints the latest value
```

4. Listening to changes:

```dart
counter.stream.listen((value) {
  print('Counter changed: $value');
});
```

5. Using with Flutter widgets:

```dart
StreamBuilder<int>(
  stream: counter.stream,
  initialData: counter.value,
  builder: (context, snapshot) {
    return Text('Count: ${snapshot.data}');
  },
)
```
6. Disposing:

```dart
@override
  void dispose() {
  counter.dispose();
  super.dispose();
}
```

7. Stream Transformations

`ReactiveSubject` provides several methods to transform streams, making reactive programming more convenient:

`map<R>(R Function(T event) mapper)`

Transforms each item emitted by the source `ReactiveSubject` by applying a function to it.

```dart
final celsiusSubject = ReactiveSubject<double>();
final fahrenheitSubject = celsiusSubject.map((celsius) => celsius * 9 / 5 + 32);

fahrenheitSubject.stream.listen((fahrenheit) {
  print('Temperature in Fahrenheit: $fahrenheit°F');
});

celsiusSubject.add(25); // Outputs: Temperature in Fahrenheit: 77.0°F
```

`where(bool Function(T event) test)`

Filters items emitted by the source `ReactiveSubject` by only emitting those that satisfy a specified predicate.

```dart
final numbers = ReactiveSubject<int>();
final evenNumbers = numbers.where((number) => number % 2 == 0);

evenNumbers.stream.listen((evenNumber) {
  print('Even number: $evenNumber');
});

numbers.add(1); // No output
numbers.add(2); // Outputs: Even number: 2

```

`debounceTime(Duration duration)`

Emits items from the source `ReactiveSubject` only after a specified duration has passed without the `ReactiveSubject` emitting any other items.

```dart
final searchQuery = ReactiveSubject<String>();
final debouncedQuery = searchQuery.debounceTime(Duration(milliseconds: 500));

debouncedQuery.stream.listen((query) {
  print('Search for: $query');
});

searchQuery.add('Flu'); // No immediate output
searchQuery.add('Flut'); // No immediate output
searchQuery.add('Flutter'); // After 500ms of inactivity, outputs: Search for: Flutter
```

`throttleTime(Duration duration)`

Emits the first item emitted by the source `ReactiveSubject` in each time window of a specified duration.

```dart
final buttonClicks = ReactiveSubject<void>();
final throttledClicks = buttonClicks.throttleTime(Duration(seconds: 1));

throttledClicks.stream.listen((_) {
  print('Button clicked');
});

buttonClicks.add(null); // Outputs: Button clicked
buttonClicks.add(null); // Ignored (within 1 second)
```

`distinct([bool Function(T previous, T next)? equals])`

Emits all items emitted by the source `ReactiveSubject` that are distinct from their immediate predecessors.

```dart
final textInput = ReactiveSubject<String>();
final distinctInput = textInput.distinct();

distinctInput.stream.listen((input) {
  print('User typed: $input');
});

textInput.add('Hello'); // Outputs: User typed: Hello
textInput.add('Hello'); // Ignored
textInput.add('World'); // Outputs: User typed: World
```

`switchMap<R>(Stream<R> Function(T event) mapper)`

Transforms the items emitted by the source `ReactiveSubject` into streams, then flattens the emissions from those into a single stream, emitting values only from the most recently created stream.

```dart
final selectedUserId = ReactiveSubject<int>();
final userDetails = selectedUserId.switchMap((id) => getUserDetailsStream(id));

userDetails.stream.listen((details) {
  print('User Details: $details');
});

void Function(int id) selectUser = selectedUserId.add;
```

`combineLatest<T>(List<ReactiveSubject<T>> subjects)`

Combines the latest values of `multiple ReactiveSubjects` into a `single ReactiveSubject` that emits a List of those values.

```dart
final firstName = ReactiveSubject<String>();
final lastName = ReactiveSubject<String>();

final fullName = ReactiveSubject.combineLatest<String>([firstName, lastName])
    .map((names) => '${names[0]} ${names[1]}');

fullName.stream.listen((name) {
  print('Full name: $name');
});

firstName.add('John');
lastName.add('Doe'); // Outputs: Full name: John Doe
```

`merge<T>(List<ReactiveSubject<T>> subjects)`

Merges `multiple ReactiveSubjects` into a `single ReactiveSubject`.

```dart
final userActions = ReactiveSubject<String>();
final systemEvents = ReactiveSubject<String>();

final allEvents = ReactiveSubject.merge<String>([userActions, systemEvents]);

allEvents.stream.listen((event) {
  print('Event: $event');
});

userActions.add('User logged in'); // Outputs: Event: User logged in
systemEvents.add('System update available'); // Outputs: Event: System update available
```

`withLatestFrom<S, R>(ReactiveSubject<S> other, R Function(T event, S latestFromOther) combiner)`

Combines the source `ReactiveSubject` with the latest item from another `ReactiveSubject` whenever the source emits an item.

```dart
final userInput = ReactiveSubject<String>();
final currentSettings = ReactiveSubject<Map<String, dynamic>>(initialValue: {'theme': 'dark'});

final combinedStream = userInput.withLatestFrom(
  currentSettings,
  (input, settings) => {'input': input, 'settings': settings},
);

combinedStream.stream.listen((data) {
  print('User Input: ${data['input']}, Settings: ${data['settings']}');
});

userInput.add('Hello'); // Outputs: User Input: Hello, Settings: {theme: dark}
```

`startWith(T startValue)`

Prepends a given value to the source `ReactiveSubject`.

```dart
final messages = ReactiveSubject<String>();
final messagesWithWelcome = messages.startWith('Welcome to the app!');

messagesWithWelcome.stream.listen((message) {
  print('Message: $message');
});

// Outputs: Message: Welcome to the app!

messages.add('You have new notifications');
// Outputs: Message: You have new notifications
```

`scan<R>(R initialValue, R Function(R accumulated, T current, int index) accumulator)`

Applies an accumulator function over the source `ReactiveSubject`, and returns each intermediate result.

```dart
final numbers = ReactiveSubject<int>();
final runningTotal = numbers.scan<int>(0, (accumulated, current, index) => accumulated + current);

runningTotal.stream.listen((total) {
  print('Running Total: $total');
});

numbers.add(5); // Outputs: Running Total: 5
numbers.add(10); // Outputs: Running Total: 15
numbers.add(3); // Outputs: Running Total: 18
```

8. Error Handling

You can add errors to a `ReactiveSubject` and listen for them:

```dart
subject.addError(Exception('An error occurred'));

subject.stream.listen(
  (data) {
    // Handle data
  },
  onError: (error) {
    print('Error: $error');
  },
);
```

9. Practical Example in BLoC

Here's how you might use `ReactiveSubject` within a `BLoC` to manage state:

```dart
class SearchBloc extends MainBloc<SearchEvent, SearchState> {
  final ReactiveSubject<String> _searchQuery = ReactiveSubject<String>();
  late final ReactiveSubject<List<String>> _searchResults;

  SearchBloc() : super(const SearchState.initial()) {
    _searchResults = _searchQuery
        .debounceTime(Duration(milliseconds: 500))
        .switchMap((query) => _performSearch(query));

    on<SearchEvent>((event, emit) {
      if (event is UpdateQuery) {
        _searchQuery.add(event.query);
      }
    });
  }

  Stream<List<String>> _performSearch(String query) async* {
    // Simulate search operation
    await Future.delayed(Duration(seconds: 1));
    yield ['Result 1 for $query', 'Result 2 for $query'];
  }

  @override
  Future<void> close() {
    _searchQuery.dispose();
    _searchResults.dispose();
    return super.close();
  }
}
```

10. Notes

Memory Management: Always dispose of your `ReactiveSubjects` when they are no longer needed to free up resources.
Error Handling: Use addError to add errors to the stream and handle them using the onError callback in your listeners.

`ReactiveSubject` simplifies working with streams in your application, providing a convenient way to manage and react to changing data. It's particularly useful in BLoCs for handling state changes and in widgets for building reactive UIs. By leveraging the built-in transformation methods, you can create powerful reactive data flows with minimal boilerplate.


## Best Practices

1. Keep your BLoCs focused on a single responsibility.
2. Use meaningful names for your events and states.
3. Leverage the `CommonBloc` for app-wide state management.
4. Always dispose of your BLoCs and ReactiveSubjects when they're no longer needed.
5. Use `blocCatch` for consistent error handling across your app.
6. Prefer composition to inheritance when creating complex BLoCs.
7. Utilize `Freezed` for creating immutable event and state classes.
8. Take advantage of Freezed's union types and pattern matching for more expressive and type-safe event handling.
9. Use the transformation methods provided by ReactiveSubject to simplify complex stream operations.
10. Ensure that all your streams are properly disposed of to prevent memory leaks.

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

# Static Methods
- `static ReactiveSubject<List<T>> combineLatest<T>(List<ReactiveSubject<T>> subjects)`: Combines the latest values of multiple subjects.
- `static ReactiveSubject<T> merge<T>(List<ReactiveSubject<T>> subjects)`: Merges multiple subjects into one.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.