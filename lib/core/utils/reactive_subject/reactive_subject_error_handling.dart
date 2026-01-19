part of 'reactive_subject.dart';

// Error handling methods for ReactiveSubject
extension ReactiveSubjectErrorHandlingExtension<T> on ReactiveSubject<T> {

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
}
