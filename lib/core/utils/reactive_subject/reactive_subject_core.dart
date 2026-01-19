part of 'reactive_subject.dart';

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

  bool _isDisposed = false;

  /// Checks if the subject has been disposed
  bool get isDisposed => _isDisposed;

  /// Adds a new value to the subject with disposal check
  ///
  /// If the subject is disposed, this method silently returns without adding the value.
  /// This prevents errors when async operations complete after disposal.
  void add(T value) {
    if (_isDisposed) {
      return; // Silently ignore if disposed to prevent errors from async operations
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

    // Create a broadcast subject with cached value
    final cached = ReactiveSubject<T>.broadcast();
    final valueToCache = cachedValue;
    if (hasCache && valueToCache != null) {
      cached.add(valueToCache);
    }
    stream.listen(
      (value) => cached.add(value),
      onError: cached.addError,
    );
    return cached;
  }
}
