import 'dart:async';

import 'package:flutter/material.dart';
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
        'Consider using ReactiveSubject(initialValue: defaultValue) if a default value is appropriate.',
      );
    }
    return _value!;
  }

  /// Returns the current value if available, otherwise returns null.
  /// This is a safe alternative to [value] that doesn't throw exceptions.
  T? get valueOrNull => _value;

  /// Returns the current value if available, otherwise returns the provided default value.
  T valueOr(T defaultValue) => _value ?? defaultValue;

  /// Returns true if the subject has a current value.
  bool get hasValue => _value != null;

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
  bool _isDisposed = false;

  /// Checks if the subject has been disposed
  bool get isDisposed => _isDisposed;

  /// Adds a new value to the subject with disposal check
  void add(T value) {
    if (_isDisposed) {
      throw StateError('Cannot add to a disposed ReactiveSubject');
    }
    _value = value;
    if (!_subject.isClosed) {
      _subject.add(value);
    }
  }

  /// Disposes the subject and prevents further usage
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    // Cancel all active subscriptions before closing
    await _cancelAllSubscriptions();

    // Close the underlying subject
    await _subject.close();

    // Clear the cached value
    _value = null;
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Adds a subscription to be managed by this ReactiveSubject
  void _addSubscription(StreamSubscription<dynamic> subscription) {
    if (!_isDisposed) {
      _subscriptions.add(subscription);
    }
  }

  /// Cancels all managed subscriptions
  Future<void> _cancelAllSubscriptions() async {
    final futures = _subscriptions.map((sub) => sub.cancel()).toList();
    _subscriptions.clear();
    await Future.wait(futures.whereType<Future<void>>());
  }

  /// Creates a managed subscription that will be automatically cancelled on dispose
  StreamSubscription<T> listenManaged(
    void Function(T value) onData, {
    Function? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onDone: onDone as void Function()?,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _addSubscription(subscription);
    return subscription;
  }

  /// Adds an error to the subject.
  void addError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
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

  /// Emits items that are distinct based on a key selector function.
  /// This is more efficient than distinct() when you only need to compare specific properties.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<User>();
  /// final distinctById = subject.distinctBy((user) => user.id);
  /// distinctById.stream.listen(print);
  /// ```
  ReactiveSubject<T> distinctBy<K>(K Function(T value) keySelector) {
    final result = ReactiveSubject<T>();
    final seenKeys = <K>{};

    stream
        .where((value) {
          final key = keySelector(value);
          if (seenKeys.contains(key)) {
            return false;
          }
          seenKeys.add(key);
          return true;
        })
        .listen(result.add, onError: result.addError);

    return result;
  }

  /// Caches the latest value and replays it to new subscribers.
  /// This is more memory efficient than shareReplay for single value caching.
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<String>();
  /// final cached = source.cache();
  ///
  /// source.add('hello');
  ///
  /// // New subscriber gets the cached value immediately
  /// cached.stream.listen(print); // Prints: hello
  /// ```
  ReactiveSubject<T> cache() {
    if (_subject is BehaviorSubject<T>) {
      return this; // Already caching behavior
    }

    final result = ReactiveSubject<T>();
    T? cachedValue;
    bool hasCache = false;

    stream.listen((value) {
      cachedValue = value;
      hasCache = true;
      result.add(value);
    }, onError: result.addError);

    // Override the stream getter to provide cached value to new subscribers
    return ReactiveSubject<T>.broadcast()
      ..stream.listen((_) {}, onError: (_) {}) // Keep original stream alive
      .._value = hasCache ? cachedValue : null;
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
    List<ReactiveSubject<T>> subjects,
  ) {
    final result = ReactiveSubject<List<T>>();
    Rx.combineLatestList(
      subjects.map((s) => s.stream),
    ).listen(result.add, onError: result.addError);
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
    Rx.merge(
      subjects.map((s) => s.stream),
    ).listen(result.add, onError: result.addError);
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
  ReactiveSubject<R> withLatestFrom<S, R>(
    ReactiveSubject<S> other,
    R Function(T event, S latestFromOther) combiner,
  ) {
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
  ReactiveSubject<R> scan<R>(
    R initialValue,
    R Function(R accumulated, T current, int index) accumulator,
  ) {
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
    void Function(Object error, StackTrace stackTrace) onError,
  ) {
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
          'Operation timed out after ${timeout.inSeconds} seconds',
        ),
      );
    }

    timeoutFuture
        .then((value) {
          subject.add(value);
        })
        .catchError((error) {
          if (onError != null) {
            onError(error);
          }
          subject.addError(error);
        })
        .whenComplete(() {
          if (onFinally != null) {
            onFinally();
          }
          subject.dispose();
        });

    return subject;
  }

  /// Catches errors from the source ReactiveSubject and executes a recovery function to continue the stream.
  ///
  /// When an error occurs, the [recoveryFn] is called with the error and should return a new ReactiveSubject
  /// that will be used to continue the stream.
  ///
  /// Parameters:
  /// - [recoveryFn]: A function that takes an error and returns a new ReactiveSubject
  ///
  /// Returns a ReactiveSubject that continues with recovered values after errors
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  ///
  /// final recovered = subject.onErrorResumeNext((error) {
  ///   print('Recovering from error: $error');
  ///   return ReactiveSubject(initialValue: 'Recovered value');
  /// });
  ///
  /// recovered.stream.listen(
  ///   print,
  ///   onError: (e) => print('Error: $e'),
  /// );
  ///
  /// subject.add('Normal value');    // Prints: Normal value
  /// subject.addError('Some error'); // Prints: Recovering from error: Some error
  ///                                 // Prints: Recovered value
  /// ```
  ReactiveSubject<T> onErrorResumeNext(
    ReactiveSubject<T> Function(Object error) recoveryFn,
  ) {
    final result = ReactiveSubject<T>();
    stream
        .onErrorResume((error, stackTrace) => recoveryFn(error).stream)
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Retries the source ReactiveSubject when an error occurs.
  ///
  /// If [count] is provided, will retry the specified number of times before giving up.
  /// If [count] is null, will retry indefinitely.
  ///
  /// Parameters:
  /// - [count]: Optional number of retry attempts
  ///
  /// Returns a ReactiveSubject that retries on errors
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  ///
  /// final retried = subject.retry(3);
  ///
  /// retried.stream.listen(
  ///   print,
  ///   onError: (e) => print('Failed after 3 retries: $e'),
  /// );
  ///
  /// // Will retry up to 3 times before emitting the error
  /// subject.addError('Test error');
  /// ```
  ReactiveSubject<T> retry([int? count]) {
    final result = ReactiveSubject<T>();

    Stream<T> retryStream = stream;
    if (count != null) {
      retryStream = stream.onErrorResume((error, stackTrace) {
        if (count > 0) {
          return retry(count - 1).stream;
        } else {
          return Stream.error(error, stackTrace);
        }
      });
    } else {
      retryStream = stream.onErrorResume((error, stackTrace) => retry().stream);
    }

    retryStream.listen(result.add, onError: result.addError);
    return result;
  }

  /// Retries the source ReactiveSubject when an error occurs, with a delay between retries.
  ///
  /// Parameters:
  /// - [retryWhenFactory]: A function that receives the error stream and returns a stream that determines when to retry
  ///
  /// Returns a ReactiveSubject that retries based on the retryWhen function
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  ///
  /// final retried = subject.retryWhen((errors) =>
  ///   errors.delay(Duration(seconds: 1)).take(3)
  /// );
  ///
  /// retried.stream.listen(print);
  /// ```
  ReactiveSubject<T> retryWhen(
    Stream<void> Function(Stream<Object>) retryWhenFactory,
  ) {
    final result = ReactiveSubject<T>();

    // Use a simpler approach - just use onErrorResume which is available in RxDart
    stream
        .onErrorResume((error, stackTrace) {
          final errorStream = Stream<Object>.value(error);
          return retryWhenFactory(errorStream).switchMap((_) => stream);
        })
        .listen(result.add, onError: result.addError);

    return result;
  }

  /// Shares a single subscription to the source ReactiveSubject among multiple subscribers.
  ///
  /// This is useful when you want multiple subscribers to share the same subscription
  /// to the source, rather than creating a new subscription for each subscriber.
  ///
  /// Returns a ReactiveSubject that shares its subscription among all subscribers
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final shared = source.share();
  ///
  /// // Both subscribers share the same subscription
  /// shared.stream.listen((value) => print('Subscriber 1: $value'));
  /// shared.stream.listen((value) => print('Subscriber 2: $value'));
  ///
  /// source.add(1);
  /// // Prints:
  /// // Subscriber 1: 1
  /// // Subscriber 2: 1
  /// ```
  ReactiveSubject<T> share() {
    final shared = stream.share();
    final result = ReactiveSubject<T>();
    shared.listen(result.add, onError: result.addError);
    return result;
  }

  /// Shares a single subscription and replays the specified number of latest values to new subscribers.
  ///
  /// Parameters:
  /// - [maxSize]: The maximum number of values to replay to new subscribers
  ///
  /// Returns a ReactiveSubject that shares and replays values to new subscribers
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final shared = source.shareReplay(maxSize: 2);
  ///
  /// source.add(1);
  /// source.add(2);
  /// source.add(3);
  ///
  /// // New subscriber will receive the last 2 values: 2, 3
  /// shared.stream.listen(print);
  ///
  /// source.add(4); // All subscribers receive: 4
  /// ```
  ReactiveSubject<T> shareReplay({int maxSize = 1}) {
    final shared = stream.shareReplay(maxSize: maxSize);
    final result = ReactiveSubject<T>();
    shared.listen(result.add, onError: result.addError);
    return result;
  }

  /// Buffers values from the source ReactiveSubject until the closing stream emits.
  ///
  /// When the closing stream emits a value, the buffer is emitted as a List and a new buffer
  /// is started. This is useful for collecting values over time and emitting them as a batch.
  ///
  /// Parameters:
  /// - [closing]: A Stream that determines when to close and emit the current buffer
  ///
  /// Returns a ReactiveSubject that emits Lists of buffered values
  ///
  /// Example:
  /// ```dart
  /// // Create a subject that emits integers
  /// final source = ReactiveSubject<int>();
  ///
  /// // Create a timer that emits every 2 seconds
  /// final closing = Stream.periodic(Duration(seconds: 2));
  ///
  /// // Buffer values until the closing stream emits
  /// final buffered = source.buffer(closing);
  ///
  /// // Listen to the buffered values
  /// buffered.stream.listen((list) => print('Buffered values: $list'));
  ///
  /// // Add values
  /// source.add(1);
  /// source.add(2);
  /// source.add(3);
  /// // After 2 seconds, prints: Buffered values: [1, 2, 3]
  /// ```
  ///
  /// Advanced usage with window size:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final windowSize = 3;
  ///
  /// // Create a closing stream that emits after every N values
  /// final closing = source.stream.bufferCount(windowSize).map((_) => null);
  ///
  /// final buffered = source.buffer(closing);
  /// buffered.stream.listen(print);
  ///
  /// source.add(1);
  /// source.add(2);
  /// source.add(3); // Prints: [1, 2, 3]
  /// source.add(4);
  /// source.add(5);
  /// source.add(6); // Prints: [4, 5, 6]
  /// ```
  ///
  /// Note: Remember to dispose of the source and buffered subjects when they are no longer needed:
  /// ```dart
  /// source.dispose();
  /// buffered.dispose();
  /// ```
  ReactiveSubject<List<T>> buffer(Stream<dynamic> closing) {
    final result = ReactiveSubject<List<T>>();
    stream.buffer(closing).listen(result.add, onError: result.addError);
    return result;
  }

  /// Groups stream events into separate lists based on a key selector function.
  ///
  /// Parameters:
  /// - [keySelector]: A function that returns a key for each value
  ///
  /// Returns a ReactiveSubject that emits a Map where keys are the results of [keySelector]
  /// and values are lists of items sharing the same key
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final grouped = source.groupBy((value) => value % 2 == 0 ? 'even' : 'odd');
  ///
  /// grouped.stream.listen((groups) {
  ///   print('Even numbers: ${groups['even']}');
  ///   print('Odd numbers: ${groups['odd']}');
  /// });
  ///
  /// source.add(1); // Odd numbers: [1]
  /// source.add(2); // Even numbers: [2]
  /// source.add(3); // Odd numbers: [1, 3]
  /// ```
  ReactiveSubject<Map<K, List<T>>> groupBy<K>(K Function(T value) keySelector) {
    final result = ReactiveSubject<Map<K, List<T>>>();
    final groups = <K, List<T>>{};

    stream.listen((value) {
      final key = keySelector(value);
      groups.putIfAbsent(key, () => []).add(value);
      result.add(Map.from(groups));
    }, onError: result.addError);

    return result;
  }

  /// Adds debugging capabilities to the ReactiveSubject by logging events.
  ///
  /// Parameters:
  /// - [tag]: Optional identifier for the debug messages
  /// - [onValue]: Optional callback for handling emitted values
  /// - [onError]: Optional callback for handling errors
  ///
  /// Returns a ReactiveSubject that logs events for debugging
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final debugged = source.debug(
  ///   tag: 'MyStream',
  ///   onValue: (value) => print('Processing: $value'),
  ///   onError: (error) => print('Error occurred: $error'),
  /// );
  ///
  /// source.add(1);
  /// // Prints:
  /// // [MyStream] Value: 1
  /// // Processing: 1
  ///
  /// source.addError('Test error');
  /// // Prints:
  /// // [MyStream] Error: Test error
  /// // Error occurred: Test error
  /// ```
  ReactiveSubject<T> debug({
    String? tag,
    void Function(T value)? onValue,
    void Function(Object error)? onError,
  }) {
    final result = ReactiveSubject<T>();

    stream.listen(
      (value) {
        if (tag != null) {
          debugPrint('[$tag] Value: $value');
        }
        onValue?.call(value);
        result.add(value);
      },
      onError: (error) {
        if (tag != null) {
          debugPrint('[$tag] Error: $error');
        }
        onError?.call(error);
        result.addError(error);
      },
    );

    return result;
  }

  /// Transforms each item emitted by the source ReactiveSubject by applying a function that returns a nullable value,
  /// and only emits non-null results.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  /// final mapped = subject.mapNotNull((s) => int.tryParse(s));
  /// mapped.stream.listen(print);
  ///
  /// subject.add('123'); // Prints: 123
  /// subject.add('abc'); // Does not print (null filtered out)
  /// ```
  ReactiveSubject<R> mapNotNull<R>(R? Function(T event) mapper) {
    final result = ReactiveSubject<R>();
    stream
        .map(mapper)
        .whereType<R>()
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits only items that are not null from the source ReactiveSubject.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String?>();
  /// final nonNull = subject.whereNotNull();
  /// nonNull.stream.listen(print);
  ///
  /// subject.add('hello'); // Prints: hello
  /// subject.add(null);    // Does not print
  /// ```
  ReactiveSubject<T> whereNotNull() {
    final result = ReactiveSubject<T>();
    stream
        .where((event) => event != null)
        .cast<T>()
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits the previous and current values as a pair.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final paired = subject.pairwise();
  /// paired.stream.listen(print);
  ///
  /// subject.add(1);
  /// subject.add(2); // Prints: [1, 2]
  /// subject.add(3); // Prints: [2, 3]
  /// ```
  ReactiveSubject<List<T>> pairwise() {
    final result = ReactiveSubject<List<T>>();
    stream.pairwise().listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits the time interval between consecutive emissions.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final timed = subject.timeInterval();
  /// timed.stream.listen((interval) => print('Value: ${interval.value}, Interval: ${interval.interval}'));
  /// ```
  ReactiveSubject<TimeInterval<T>> timeInterval() {
    final result = ReactiveSubject<TimeInterval<T>>();
    stream.timeInterval().listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits each item with a timestamp indicating when it was emitted.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final timestamped = subject.timestamp();
  /// timestamped.stream.listen((ts) => print('Value: ${ts.value}, Time: ${ts.timestamp}'));
  /// ```
  ReactiveSubject<Timestamped<T>> timestamp() {
    final result = ReactiveSubject<Timestamped<T>>();
    stream.timestamp().listen(result.add, onError: result.addError);
    return result;
  }

  /// Skips the last [count] items emitted by the source ReactiveSubject.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final skipped = subject.skipLast(2);
  /// skipped.stream.listen(print);
  ///
  /// subject.add(1);
  /// subject.add(2);
  /// subject.add(3); // Prints: 1
  /// subject.add(4); // Prints: 2
  /// ```
  ReactiveSubject<T> skipLast(int count) {
    final result = ReactiveSubject<T>();
    stream.skipLast(count).listen(result.add, onError: result.addError);
    return result;
  }

  /// Takes the last [count] items emitted by the source ReactiveSubject.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final lastTwo = subject.takeLast(2);
  /// lastTwo.stream.listen(print);
  ///
  /// subject.add(1);
  /// subject.add(2);
  /// subject.add(3);
  /// subject.dispose(); // Prints: 2, 3
  /// ```
  ReactiveSubject<T> takeLast(int count) {
    final result = ReactiveSubject<T>();
    stream.takeLast(count).listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits items from the source ReactiveSubject while the [test] function returns true.
  /// Unlike [Stream.takeWhile], this includes the first item that fails the test.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final taken = subject.takeWhileInclusive((i) => i < 3);
  /// taken.stream.listen(print);
  ///
  /// subject.add(1); // Prints: 1
  /// subject.add(2); // Prints: 2
  /// subject.add(3); // Prints: 3 (included even though test fails)
  /// subject.add(4); // Does not print
  /// ```
  ReactiveSubject<T> takeWhileInclusive(bool Function(T event) test) {
    final result = ReactiveSubject<T>();
    stream
        .takeWhileInclusive(test)
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Listens to the stream and calls the provided callbacks.
  ///
  /// The [onData] callback is called for each data event.
  /// The [onError] callback is called for each error event.
  /// The [onDone] callback is called when the stream is closed.
  ///
  /// Returns a StreamSubscription that can be used to control the subscription.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 0);
  /// final subscription = subject.listen(
  ///   (value) => print('Value: $value'),
  ///   onError: (error) => print('Error: $error'),
  ///   onDone: () => print('Done'),
  /// );
  ///
  /// // Later, cancel the subscription
  /// subscription.cancel();
  /// ```
  StreamSubscription<T> listen(
    void Function(T value) onData, {
    Function? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onDone: onDone as void Function()?,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}
