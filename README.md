# bloc_small

## Getting Started

A library that aims to make it simple to use the BLoC design pattern to separate presentation code from business logic and state. While this library aims to make the project 100% compliant with the BLoC pattern, it also acknowledges that 100% compliance is not always advisable or necessary.
This library has been customized to make BloC easier to understand, avoid useless function calls, and focus on solving logic.

## How to use

```dart
class CounterBloc {
  var _counter = Bloc<int>.broadcast(initialValue: 0);

  void incrementCounter() {
    _counter.add(_counter.value + 1);
  }

  void decrementCounter() {
    if (_counter.value > 0) _counter.add(_counter.value - 1);
  }

  void dispose() {
    _counter.dispose();
  }
}
```
The bloc can now be used elsewhere in the project:

```dart
  final bloc = CounterBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bloc.dispose();
  }
```
wrap it with StreamBuilder to listen for changed events and return data:

```dart
  StreamBuilder<int>(
                initialData: bloc._counter.value,
                stream: bloc._counter.stream,
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data}',
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),

  floatingActionButton: Wrap(
    spacing: 5,
    children: [
      FloatingActionButton(
        onPressed: bloc.incrementCounter, //__counter + 1
        tooltip: 'Increment',
      child: Icon(Icons.add),
    ),
      FloatingActionButton(
        onPressed: bloc.decrementCounter, //__counter - 1
        tooltip: 'decrement',
        child: Icon(Icons.remove),
    ),
  ],
), //
```
