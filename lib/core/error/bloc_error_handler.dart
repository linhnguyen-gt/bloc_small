import 'dart:async' as async;
import 'dart:developer' as developer;

import 'exceptions.dart';

/// Standardized error handling for Blocs and Cubits.
///
/// This is the single error-handler mixin. It replaces the previous four
/// overlapping names — `BlocErrorHandlerMixin`, `CubitErrorHandlerMixin`
/// (byte-identical to each other), the abstract `BaseErrorHandlerMixin`, and
/// the separate `CubitErrorHandler`. None of them carried bloc- or
/// cubit-specific behaviour, so nothing is lost by collapsing them, and there
/// is now exactly one implementation of [retryOperation] and [getErrorMessage].
///
/// It declares no `on` clause, so it applies to both:
/// ```dart
/// class MyBloc extends MainBloc<MyEvent, MyState> with BaseErrorHandlerMixin {
///   Future<void> _onFetch(Fetch event, Emitter<MyState> emit) async {
///     await blocCatch(actions: _fetch, onError: handleError);
///   }
/// }
///
/// class MyCubit extends MainCubit<MyState> with BaseErrorHandlerMixin {
///   Future<void> fetch() async {
///     await cubitCatch(actions: _fetch, onError: handleError);
///   }
/// }
/// ```
///
/// The mixin deliberately does **not** hide loading. See [handleError].
mixin BaseErrorHandlerMixin {
  /// Retries [operation] until it succeeds or [maxAttempts] is reached.
  ///
  /// Returns the operation's value — the previous signature declared `<T>` but
  /// returned `Future<void>`, discarding the result it had just awaited.
  ///
  /// Retries on [Exception] only. An [Error] signals a bug rather than a
  /// transient failure, and retrying one re-runs whatever side effects the
  /// operation already performed — an emit-after-close `StateError` used to
  /// produce three duplicate requests before finally rethrowing.
  ///
  /// Parameters:
  /// - [operation]: the work to attempt
  /// - [maxAttempts]: how many times to try in total (default: 3)
  /// - [delay]: pause between attempts (default: 1 second)
  ///
  /// Throws the last error if every attempt fails.
  Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await operation();
      } on Exception {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(delay);
      }
    }
  }

  /// Converts an error object into a user-friendly message.
  ///
  /// Handles:
  /// - [NetworkException]
  /// - [ValidationException]
  /// - [AppTimeoutException] and `dart:async`'s `TimeoutException`
  /// - any other [AppException], via its own message
  String getErrorMessage(Object error) {
    return switch (error) {
      NetworkException() => 'Please check your internet connection',
      AppTimeoutException() || async.TimeoutException() =>
        'The operation timed out',
      // Covers ValidationException and any future AppException subtype, which
      // otherwise fell through to the generic message.
      AppException() => error.message,
      _ => 'An unexpected error occurred',
    };
  }

  /// Logs [error] and its [stackTrace].
  ///
  /// Does **not** hide loading. `catchError`'s `finally` owns that, and it is
  /// the only place guaranteed to pair with the matching `showLoading`. Hiding
  /// here too would decrement the loading refcount twice for a single
  /// increment, clearing the spinner while a concurrent operation on the same
  /// key was still running.
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    developer.log(
      'Error occurred',
      error: error,
      name: runtimeType.toString(),
      time: DateTime.now(),
      level: 1000,
      stackTrace: stackTrace,
    );
  }
}
