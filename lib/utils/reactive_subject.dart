import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// A wrapper class for RxDart subjects that provides a simplified interface for reactive programming.
///
/// This class encapsulates either a BehaviorSubject or a PublishSubject and provides methods
/// to interact with the underlying subject in a more convenient way.
///
/// Usage:
/// ```dart
/// // Create a ReactiveSubject with an initial value
/// final subject = ReactiveSubject<int>(initialValue: 0);
///
/// // Add a value
/// subject.add(1);
///
/// // Listen to the stream
/// subject.stream.listen((value) => print(value));
///
/// // Get the current value
/// print(subject.value);
///
/// // Dispose when done
/// subject.dispose();
/// ```
///
/// Usage with StreamBuilder in a widget:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final ReactiveSubject<int> _counter = ReactiveSubject<int>(initialValue: 0);
///
///   @override
///   void dispose() {
///     _counter.dispose();
///     super.dispose();
///   }
///
///   void _incrementCounter() {
///     _counter.add(_counter.value + 1);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: StreamBuilder<int>(
///           stream: _counter.stream,
///           builder: (context, snapshot) {
///             if (snapshot.hasData) {
///               return Text('Counter: ${snapshot.data}');
///             } else {
///               return CircularProgressIndicator();
///             }
///           },
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: _incrementCounter,
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
class ReactiveSubject<T> {
  /// Creates a ReactiveSubject with a BehaviorSubject.
  ///
  /// [initialValue] is the initial value of the subject, if provided.
  ReactiveSubject({T? initialValue}) : _subject = BehaviorSubject<T>() {
    if (initialValue != null) {
      _value = initialValue;
      add(initialValue);
    }
  }

  /// Creates a ReactiveSubject with a PublishSubject.
  ///
  /// Use this constructor when you need multiple subscribers to receive updates
  /// independently. Note that late subscribers will only receive values that are
  /// added after they subscribe.
  ///
  /// [initialValue] is the initial value of the subject, if provided.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>.broadcast(initialValue: 0);
  ///
  /// // First subscriber
  /// subject.stream.listen((value) => print('Subscriber 1: $value'));
  ///
  /// // Second subscriber
  /// subject.stream.listen((value) => print('Subscriber 2: $value'));
  ///
  /// subject.add(1); // Both subscribers will receive this value
  /// ```
  ReactiveSubject.broadcast({T? initialValue})
      : _subject = PublishSubject<T>() {
    if (initialValue != null) {
      _value = initialValue;
      add(initialValue);
    }
  }

  late T? _value;

  /// The current value of the subject.
  ///
  /// Throws a [StateError] if no value has been added and no initial value was provided.
  T get value {
    if (_value == null) {
      throw StateError(
          'No value available. Ensure an initial value was provided or a value has been added. '
          'Consider using ReactiveSubject(initialValue: defaultValue) if a default value is appropriate.');
    }
    return _value!;
  }

  final Subject<T> _subject;

  /// The stream of the underlying subject.
  Stream<T> get stream => _subject.stream;

  /// The sink of the underlying subject.
  Sink<T> get sink => _subject.sink;

  /// Whether the underlying subject is closed.
  bool get isClosed => _subject.isClosed;

  /// Adds a new value to the subject.
  ///
  /// Updates the current value and adds it to the stream if the subject is not closed.
  void add(T value) {
    _value = value;
    if (!_subject.isClosed) {
      _subject.add(value);
    }
  }

  /// Adds an error to the subject.
  void addError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
  }

  /// Closes the underlying subject.
  Future<void> dispose() async {
    await _subject.close();
  }

  /// Transforms the items emitted by the source ReactiveSubject by applying a function to each item.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final doubled = subject.map((i) => i * 2);
  /// doubled.stream.listen(print); // Prints: 2
  /// subject.add(2); // Prints: 4
  /// ```
  ReactiveSubject<R> map<R>(R Function(T event) mapper) {
    final result = ReactiveSubject<R>();
    stream.map(mapper).listen(result.add, onError: result.addError);
    return result;
  }

  /// Filters the items emitted by the source ReactiveSubject by only emitting those that satisfy a specified predicate.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final evens = subject.where((i) => i % 2 == 0);
  /// evens.stream.listen(print);
  /// subject.add(2); // Prints: 2
  /// subject.add(3); // Does not print
  /// ```
  ReactiveSubject<T> where(bool Function(T event) test) {
    final result = ReactiveSubject<T>();
    stream.where(test).listen(result.add, onError: result.addError);
    return result;
  }

  /// Transforms the items emitted by the source ReactiveSubject by applying a function that returns a ReactiveSubject, then emitting the items emitted by the most recently created ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final switched = subject.switchMap((i) => ReactiveSubject<String>(initialValue: 'Value: $i'));
  /// switched.stream.listen(print);
  /// subject.add(2); // Prints: Value: 2
  /// ```
  ReactiveSubject<R> switchMap<R>(ReactiveSubject<R> Function(T event) mapper) {
    final newSubject = ReactiveSubject<R>();
    stream
        .switchMap((event) => mapper(event).stream)
        .listen(newSubject.add, onError: newSubject.addError);
    return newSubject;
  }

  /// Emits items from the source ReactiveSubject only after a specified duration has passed without the ReactiveSubject emitting any other items.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  /// final debounced = subject.debounceTime(Duration(seconds: 1));
  /// debounced.stream.listen(print);
  /// subject.add('a');
  /// subject.add('b');
  /// subject.add('c'); // After 1 second, prints: c
  /// ```
  ReactiveSubject<T> debounceTime(Duration duration) {
    final result = ReactiveSubject<T>();
    stream.debounceTime(duration).listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits the first item emitted by the source ReactiveSubject in each time window of a specified duration.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final throttled = subject.throttleTime(Duration(seconds: 1));
  /// throttled.stream.listen(print);
  /// subject.add(1); // Prints: 1
  /// subject.add(2);
  /// subject.add(3); // After 1 second, prints: 3
  /// ```
  ReactiveSubject<T> throttleTime(Duration duration) {
    final result = ReactiveSubject<T>();
    stream.throttleTime(duration).listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits all items emitted by the source ReactiveSubject that are distinct from their immediate predecessors.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final distinct = subject.distinct();
  /// distinct.stream.listen(print);
  /// subject.add(1); // Prints: 1
  /// subject.add(1);
  /// subject.add(2); // Prints: 2
  /// ```
  ReactiveSubject<T> distinct([bool Function(T previous, T next)? equals]) {
    final result = ReactiveSubject<T>();
    stream.distinct(equals).listen(result.add, onError: result.addError);
    return result;
  }

  /// Combines the latest values of multiple ReactiveSubjects into a single ReactiveSubject that emits a List of those values.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<String>(initialValue: 'a');
  /// final combined = ReactiveSubject.combineLatest([subject1, subject2]);
  /// combined.stream.listen(print); // Prints: [1, 'a']
  /// subject1.add(2); // Prints: [2, 'a']
  /// ```
  static ReactiveSubject<List<T>> combineLatest<T>(
      List<ReactiveSubject<T>> subjects) {
    final result = ReactiveSubject<List<T>>();
    Rx.combineLatestList(subjects.map((s) => s.stream))
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Merges multiple ReactiveSubjects into a single ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<int>(initialValue: 2);
  /// final merged = ReactiveSubject.merge([subject1, subject2]);
  /// merged.stream.listen(print); // Prints: 1, 2
  /// subject1.add(3); // Prints: 3
  /// ```
  static ReactiveSubject<T> merge<T>(List<ReactiveSubject<T>> subjects) {
    final result = ReactiveSubject<T>();
    Rx.merge(subjects.map((s) => s.stream))
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Combines the latest values of two ReactiveSubjects using a specified combiner function.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<String>(initialValue: 'a');
  /// final combined = subject1.withLatestFrom(subject2, (int a, String b) => '$a$b');
  /// combined.stream.listen(print); // Prints: 1a
  /// subject1.add(2); // Prints: 2a
  /// ```
  ReactiveSubject<R> withLatestFrom<S, R>(ReactiveSubject<S> other,
      R Function(T event, S latestFromOther) combiner) {
    final result = ReactiveSubject<R>();
    stream
        .withLatestFrom(other.stream, combiner)
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Prepends a given value to the source ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final started = subject.startWith(0);
  /// started.stream.listen(print); // Prints: 0, 1
  /// subject.add(2); // Prints: 2
  /// ```
  ReactiveSubject<T> startWith(T startValue) {
    final result = ReactiveSubject<T>(initialValue: startValue);
    stream.startWith(startValue).listen(result.add, onError: result.addError);
    return result;
  }

  /// Applies an accumulator function over the source ReactiveSubject, and returns each intermediate result as a ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final sum = subject.scan<int>(0, (accumulated, current, index) => accumulated + current);
  /// sum.stream.listen(print); // Prints: 1
  /// subject.add(2); // Prints: 3
  /// subject.add(3); // Prints: 6
  /// ```
  ReactiveSubject<R> scan<R>(R initialValue,
      R Function(R accumulated, T current, int index) accumulator) {
    final result = ReactiveSubject<R>();
    stream
        .scan(accumulator, initialValue)
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Performs a side-effect action for each data event emitted by the source ReactiveSubject.
  ///
  /// The [onData] callback receives the emitted item but does not modify it.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final sideEffect = subject.doOnData((value) => print('Value emitted: $value'));
  /// sideEffect.stream.listen(print); // Prints: Value emitted: 1, then 1
  /// subject.add(2); // Prints: Value emitted: 2, then 2
  /// ```
  ReactiveSubject<T> doOnData(void Function(T event) onData) {
    final newSubject = ReactiveSubject<T>();
    stream
        .doOnData(onData)
        .listen(newSubject.add, onError: newSubject.addError);
    return newSubject;
  }

  /// Performs a side-effect action for each error event emitted by the source ReactiveSubject.
  ///
  /// The [onError] callback receives the error and stack trace but does not modify them.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final sideEffect = subject.doOnError((error, stackTrace) => print('Error: $error'));
  /// sideEffect.stream.listen(print, onError: (e) => print('Stream error: $e'));
  /// subject.addError('An error occurred'); // Prints: Error: An error occurred, then Stream error: An error occurred
  /// ```
  ReactiveSubject<T> doOnError(
      void Function(Object error, StackTrace stackTrace) onError) {
    final newSubject = ReactiveSubject<T>();
    stream
        .doOnError(onError)
        .listen(newSubject.add, onError: newSubject.addError);
    return newSubject;
  }

  /// Creates a ReactiveSubject from a Future, with error handling and completion callback.
  ///
  /// [future] is the Future to convert into a ReactiveSubject.
  /// [onError] is an optional callback to handle errors.
  /// [onFinally] is an optional callback that runs when the Future completes.
  /// [timeout] is an optional duration after which the Future will time out.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject.fromFutureWithError(
  ///   Future.delayed(Duration(seconds: 1), () => 'Result'),
  ///   onError: (error) => print('Error occurred: $error'),
  ///   onFinally: () => print('Operation completed'),
  /// );
  ///
  /// subject.stream.listen(
  ///   (value) => print('Received: $value'),
  ///   onError: (error) => print('Stream error: $error'),
  ///   onDone: () => print('Stream closed'),
  /// );
  ///
  /// // Output:
  /// // Received: Result
  /// // Operation completed
  /// // Stream closed
  /// ```
  ///
  /// Error handling example:
  /// ```dart
  /// final subject = ReactiveSubject.fromFutureWithError(
  ///   Future.delayed(Duration(seconds: 1), () => throw Exception('Test error')),
  ///   onError: (error) => print('Error occurred: $error'),
  ///   onFinally: () => print('Operation completed'),
  /// );
  ///
  /// subject.stream.listen(
  ///   (value) => print('Received: $value'),
  ///   onError: (error) => print('Stream error: $error'),
  ///   onDone: () => print('Stream closed'),
  /// );
  ///
  /// // Output:
  /// // Error occurred: Exception: Test error
  /// // Stream error: Exception: Test error
  /// // Operation completed
  /// // Stream closed
  /// ```
  static ReactiveSubject<T> fromFutureWithError<T>(
    Future<T> future, {
    Function(Object error)? onError,
    Function()? onFinally,
    Duration? timeout,
  }) {
    final subject = ReactiveSubject<T>();

    Future<T> timeoutFuture = future;
    if (timeout != null) {
      timeoutFuture = future.timeout(
        timeout,
        onTimeout: () => throw TimeoutException(
            'Operation timed out after ${timeout.inSeconds} seconds'),
      );
    }

    timeoutFuture.then((value) {
      subject.add(value);
    }).catchError((error) {
      if (onError != null) {
        onError(error);
      }
      subject.addError(error);
    }).whenComplete(() {
      if (onFinally != null) {
        onFinally();
      }
      subject.dispose();
    });

    return subject;
  }
}
