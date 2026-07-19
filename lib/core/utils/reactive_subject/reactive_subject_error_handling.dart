part of 'reactive_subject.dart';

// Error handling methods for ReactiveSubject
extension ReactiveSubjectErrorHandlingExtension<T> on ReactiveSubject<T> {

  /// Catches errors from the source ReactiveSubject and executes a recovery function to continue the stream.
  ///
  /// When an error occurs, the [recoveryFn] is called with the error and should return a new ReactiveSubject
  /// that will be used to continue the stream.
  ///
  /// Each time [recoveryFn] produces a new recovery subject, the previous one
  /// is disposed — including the final one once the result is disposed.
  /// Previously every subject a recovery call allocated was dropped without
  /// ever being disposed, the same per-event leak as `switchMap` (C9b).
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
    ReactiveSubject<T>? activeRecovery;

    void disposeActiveRecovery() {
      final recovery = activeRecovery;
      activeRecovery = null;
      if (recovery != null) {
        unawaited(recovery.dispose());
      }
    }

    final result = _deriveReactiveSubject<T>(
      stream.onErrorResume((error, stackTrace) {
        disposeActiveRecovery();
        final recovery = recoveryFn(error);
        activeRecovery = recovery;
        return recovery.stream;
      }),
    );
    result._onDispose(disposeActiveRecovery);
    return result;
  }

  /// Retries the source ReactiveSubject when an error occurs.
  ///
  /// If [count] is provided, will retry the specified number of times before giving up.
  /// If [count] is null, will retry indefinitely.
  ///
  /// **Known limitation:** `ReactiveSubject` wraps a value stream, not a
  /// re-runnable task, so "retry" here can only mean "re-subscribe to the
  /// same source". If the source is `BehaviorSubject`-backed (the default
  /// constructor), it replays its most recently emitted item *or error* to
  /// every new subscriber — so re-subscribing after an error immediately
  /// replays that same cached error again, consuming one of [count]
  /// attempts without the source ever doing new work. The retries are real
  /// (each one is a fresh subscription, and the orphan subject each attempt
  /// used to allocate is now disposed instead of leaked), but they cannot
  /// cause a different outcome unless something else pushes a new, distinct
  /// value onto the source in between. For a stream backed by genuinely
  /// re-runnable work, retry around the work itself (e.g. wrap the
  /// `Future`-producing function passed to [fromFutureWithError] in your own
  /// retry loop) rather than retrying the resulting subject.
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
    ReactiveSubject<T>? activeRetry;

    void disposeActiveRetry() {
      final active = activeRetry;
      activeRetry = null;
      if (active != null) {
        unawaited(active.dispose());
      }
    }

    final retryStream = stream.onErrorResume((error, stackTrace) {
      if (count != null && count <= 0) {
        return Stream<T>.error(error, stackTrace);
      }
      disposeActiveRetry();
      final next = retry(count == null ? null : count - 1);
      activeRetry = next;
      return next.stream;
    });

    final result = _deriveReactiveSubject<T>(retryStream);
    result._onDispose(disposeActiveRetry);
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
    // Use a simpler approach - just use onErrorResume which is available in RxDart
    return _deriveReactiveSubject<T>(
      stream.onErrorResume((error, stackTrace) {
        final errorStream = Stream<Object>.value(error);
        return retryWhenFactory(errorStream).switchMap((_) => stream);
      }),
    );
  }
}
