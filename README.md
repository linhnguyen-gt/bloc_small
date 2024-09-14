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
- Integration with GetIt for dependency injection
- Support for loading states and error handling
- Streamlined state updates and event handling
- Built-in support for asynchronous operations
- Seamless integration with Freezed for immutable state and event classes

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
> Note: ReactiveSubject uses RxDart internally. Make sure you have `rxdart` in your `pubspec.yaml` dependencies.

ReactiveSubject provides a simple way to create and manage streams of data in your application. Here's a guide on how to use it:

1. Creating a ReactiveSubject:

```dart
// For a single-subscription subject with an initial value
final counter = ReactiveSubject<int>(initialValue: 0);
// For a broadcast subject (multiple listeners)
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

ReactiveSubject simplifies working with streams in your application, providing a convenient way to manage and react to changing data. It's particularly useful in BLoCs for handling state changes and in widgets for building reactive UIs.


## Best Practices

1. Keep your BLoCs focused on a single responsibility.
2. Use meaningful names for your events and states.
3. Leverage the `CommonBloc` for app-wide state management.
4. Always dispose of your BLoCs and ReactiveSubjects when they're no longer needed.
5. Use `blocCatch` for consistent error handling across your app.
6. Prefer composition to inheritance when creating complex BLoCs.
7. Utilize Freezed for creating immutable event and state classes.
8. Take advantage of Freezed's union types and pattern matching for more expressive and type-safe event handling.

## API Reference

### MainBloc

- `MainBloc(initialState)`: Constructor for creating a new BLoC.
- `blocCatch({required Future<void> Function() actions, Function(dynamic)? onError})`: Wrapper for handling errors in
  async operations.

### MainBlocState

Base class for all states in your BLoCs.

### MainBlocEvent

Base class for all events in your BLoCs.

### CommonBloc

- `add(SetComponentLoading)`: Set loading state for a component.
- `state.isLoading(String key)`: Check if a component is in loading state.

### ReactiveSubject

`ReactiveSubject` is a wrapper around RxDart's `BehaviorSubject` or `PublishSubject`, providing a simpler API for reactive programming in Dart.

- `ReactiveSubject({T? initialValue})`: Create a new ReactiveSubject (wraps BehaviorSubject).
- `ReactiveSubject.broadcast({T? initialValue})`: Create a new broadcast ReactiveSubject (wraps PublishSubject).
- `add(T value)`: Add a new value to the subject.
- `value`: Get the current value.
- `stream`: Get the stream of values.
- `dispose()`: Dispose of the subject.


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.