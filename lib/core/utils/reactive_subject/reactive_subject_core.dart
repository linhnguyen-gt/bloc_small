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
///
/// Derived subjects (the result of `.map()`, `.where()`, `.switchMap()`, and
/// every other operator in this library) own the subscription to their
/// source: disposing a derived subject cancels that subscription, and
/// disposing the source forwards completion to every subject derived from
/// it. Neither side can outlive the other by accident.
class ReactiveSubject<T> {
  /// Creates a ReactiveSubject with a BehaviorSubject.
  ///
  /// [initialValue] is the initial value of the subject, if provided.
  ReactiveSubject({T? initialValue}) : _subject = BehaviorSubject<T>() {
    assert(() {
      debugActiveInstanceCount++;
      return true;
    }());
    if (initialValue != null) {
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
    assert(() {
      debugActiveInstanceCount++;
      return true;
    }());
    if (initialValue != null) {
      add(initialValue);
    }
  }

  /// Creates a ReactiveSubject backed by a caller-supplied [Subject], e.g. a
  /// [ReplaySubject] for `shareReplay`. Internal only: callers outside this
  /// library always get a [BehaviorSubject] or [PublishSubject] through the
  /// public constructors.
  ReactiveSubject._withSubject(this._subject) {
    assert(() {
      debugActiveInstanceCount++;
      return true;
    }());
  }

  /// Debug-only count of `ReactiveSubject` instances that have been
  /// constructed but not yet disposed. Incremented by every constructor and
  /// decremented once by [dispose]; compiled out of release builds because
  /// it only runs inside `assert()`. Tests use it to prove an operator does
  /// not leak instances (e.g. a per-event subject that is never disposed),
  /// which is otherwise unobservable from Dart without heap inspection.
  @visibleForTesting
  static int debugActiveInstanceCount = 0;

  // Not `late`: a fresh subject legitimately holds no value, and `late` made
  // `valueOrNull` throw a LateInitializationError instead of returning null (C1).
  T? _value;

  // Tracks whether a value has ever been set, independent of whether that
  // value is itself `null`. Using `_value != null` as a stand-in for "has a
  // value" (the previous approach) meant `ReactiveSubject<String?>()..add(null)`
  // reported `hasValue == false` and `.value` threw, even though `null` is a
  // legitimate value for a nullable T (I14).
  bool _hasValue = false;

  /// The current value of the subject.
  ///
  /// Throws a [StateError] if no value has been added and no initial value was provided.
  T get value {
    if (!_hasValue) {
      throw StateError(
        'No value available. Ensure an initial value was provided or a value has been added. '
        'Consider using ReactiveSubject(initialValue: defaultValue) if a default value is appropriate.',
      );
    }
    return _value as T;
  }

  /// Returns the current value if available, otherwise returns null.
  /// This is a safe alternative to [value] that doesn't throw exceptions.
  T? get valueOrNull => _hasValue ? _value : null;

  /// Returns the current value if available, otherwise returns the provided default value.
  T valueOr(T defaultValue) => _hasValue ? (_value as T) : defaultValue;

  /// Returns true if the subject has a current value. This is `true` even if
  /// that value is `null` (for a nullable `T`) as long as one was set via
  /// the constructor's `initialValue` or via [add].
  bool get hasValue => _hasValue;

  final Subject<T> _subject;

  /// The stream of the underlying subject.
  Stream<T> get stream => _subject.stream;

  /// The sink of the underlying subject.
  ///
  /// Routes writes through [add], so they respect the same dispose guard and
  /// keep [value]/[hasValue] in sync. Writing directly to the wrapped
  /// [Subject]'s own sink bypassed both (I15).
  Sink<T> get sink => _GuardedSink<T>(this);

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
    _hasValue = true;
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

    // Run resource-cleanup callbacks (e.g. an operator's currently-active
    // inner subject) before cancelling subscriptions, so nothing they touch
    // has been torn down yet.
    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();

    // Cancel all active subscriptions before closing
    await _cancelAllSubscriptions();

    // Close the underlying subject
    await _subject.close();

    // Clear the cached value
    _value = null;
    _hasValue = false;

    assert(() {
      debugActiveInstanceCount--;
      return true;
    }());
  }

  final List<void Function()> _disposeCallbacks = [];

  /// Registers a callback that runs once, at the start of [dispose].
  ///
  /// Used by operators that own a resource beyond a single
  /// [StreamSubscription] — for example `switchMap`'s currently-active inner
  /// subject — so that resource is released regardless of whether disposal
  /// was triggered by the caller or by the source's `onDone` forwarding.
  void _onDispose(void Function() callback) {
    if (_isDisposed) {
      callback();
    } else {
      _disposeCallbacks.add(callback);
    }
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
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    final subscription = stream.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
    _addSubscription(subscription);
    return subscription;
  }

  /// Adds an error to the subject.
  ///
  /// If the subject is disposed or already closed, this silently returns
  /// instead of forwarding to a closed [Subject] — the same guard [add] has
  /// always had (I13).
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_isDisposed || _subject.isClosed) {
      return;
    }
    _subject.addError(error, stackTrace);
  }

  /// Combines the latest values of multiple ReactiveSubjects into a single ReactiveSubject that emits a List of those values.
  ///
  /// The result completes once every source subject does (C9c): previously
  /// it never forwarded completion, so listeners relying on `onDone` (e.g.
  /// `await for`) would hang forever even after all sources were disposed.
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
    return _deriveReactiveSubject<List<T>>(
      Rx.combineLatestList(subjects.map((s) => s.stream)),
    );
  }

  /// Merges multiple ReactiveSubjects into a single ReactiveSubject.
  ///
  /// The result completes once every source subject does (C9c), matching
  /// [combineLatest].
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
    return _deriveReactiveSubject<T>(Rx.merge(subjects.map((s) => s.stream)));
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

}

/// Creates a new [ReactiveSubject] that subscribes to [source] and forwards
/// every event to it, seeding [into] if given rather than a fresh subject.
///
/// The subscription is owned by the returned subject (D4): it is cancelled
/// in the subject's own [ReactiveSubject.dispose], and if [source] finishes,
/// the returned subject disposes itself so a closed parent cannot leave a
/// derived subject dangling — without this, listeners waiting on `onDone`
/// (an `await for` loop, a `StreamBuilder`) would hang forever after the
/// upstream subject was disposed.
ReactiveSubject<R> _deriveReactiveSubject<R>(
  Stream<R> source, {
  ReactiveSubject<R>? into,
}) {
  final result = into ?? ReactiveSubject<R>();
  final subscription = source.listen(
    result.add,
    onError: result.addError,
    onDone: () => unawaited(result.dispose()),
  );
  result._addSubscription(subscription);
  return result;
}

/// A [Sink] that routes writes through [ReactiveSubject.add] and disposal
/// through [ReactiveSubject.dispose], so both respect the same guard and
/// value-tracking that direct calls to those methods get. See [ReactiveSubject.sink].
class _GuardedSink<T> implements Sink<T> {
  _GuardedSink(this._owner);

  final ReactiveSubject<T> _owner;

  @override
  void add(T data) => _owner.add(data);

  @override
  void close() {
    unawaited(_owner.dispose());
  }
}
