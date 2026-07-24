part of 'reactive_subject.dart';

// Utility methods for ReactiveSubject
extension ReactiveSubjectUtilitiesExtension<T> on ReactiveSubject<T> {
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
    return _deriveReactiveSubject<T>(stream.doOnData(onData));
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
    return _deriveReactiveSubject<T>(stream.doOnError(onError));
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
    final logged = stream
        .doOnData((value) {
          if (tag != null) {
            debugPrint('[$tag] Value: $value');
          }
          onValue?.call(value);
        })
        .doOnError((error, stackTrace) {
          if (tag != null) {
            debugPrint('[$tag] Error: $error');
          }
          onError?.call(error);
        });
    return _deriveReactiveSubject<T>(logged);
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
    return _deriveReactiveSubject<List<T>>(stream.pairwise());
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
    return _deriveReactiveSubject<TimeInterval<T>>(stream.timeInterval());
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
    return _deriveReactiveSubject<Timestamped<T>>(stream.timestamp());
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
    return _deriveReactiveSubject<T>(stream.skipLast(count));
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
    return _deriveReactiveSubject<T>(stream.takeLast(count));
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
    return _deriveReactiveSubject<T>(stream.takeWhileInclusive(test));
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
    void Function()? onDone,
    Function? onError,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}
