import 'dart:async' show TimeoutException;
import 'dart:developer' as developer;

import '../bloc/main_bloc.dart';
import '../main_bloc_event.dart';
import '../main_bloc_state.dart';
import 'exceptions.dart';

/// A mixin that provides error handling capabilities for Blocs.
///
/// This mixin can be used to add standardized error handling to any Bloc
/// that extends [MainBloc].
///
/// Usage:
/// ```dart
/// class MyBloc extends MainBloc<MyEvent, MyState> with BlocErrorHandler<MyEvent, MyState> {
///   MyBloc() : super(MyInitialState());
///
///   Future<void> _onSomeEvent(SomeEvent event, Emitter<MyState> emit) async {
///     await blocCatch(
///       actions: () async {
///         // Your logic here that might throw
///         throw Exception('Something went wrong');
///       },
///       onError: handleError, // Uses the mixin's error handler
///     );
///   }
///
///   // Optionally override handleError for custom handling
///   @override
///   Future<void> handleError(Object error, StackTrace stackTrace) async {
///     // Custom error handling
///     super.handleError(error, stackTrace);
///     emit(state.copyWith(error: error.toString()));
///   }
/// }
/// ```
///
/// The mixin provides:
/// - Default error logging
/// - Integration with [blocCatch]
/// - Extensible error handling through method override
mixin BlocErrorHandlerMixin<Event extends MainBlocEvent,
    State extends MainBlocState> on MainBloc<Event, State> {
  /// Handles errors that occur within the Bloc.
  ///
  /// By default, this method logs the error using the developer console.
  /// Override this method to provide custom error handling.
  ///
  /// Parameters:
  /// - [error]: The error that occurred
  /// - [stackTrace]: The stack trace associated with the error
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> handleError(Object error, StackTrace stackTrace) async {
  ///   // Custom error handling
  ///   super.handleError(error, stackTrace);
  ///   emit(state.copyWith(error: error.toString()));
  ///   // Additional error handling like analytics
  ///   analytics.logError(error, stackTrace);
  /// }
  /// ```
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    developer.log(
      'Bloc error occurred',
      error: error,
      name: runtimeType.toString(),
      time: DateTime.now(),
      level: 1000,
      stackTrace: stackTrace,
    );

    hideLoading();
  }

  /// Retries an operation until it succeeds or reaches the maximum number of attempts.
  ///
  /// Parameters:
  /// - [operation]: A function that returns a Future to be retried
  /// - [maxAttempts]: The maximum number of attempts to retry the operation
  /// - [delay]: The delay between attempts
  ///
  /// Returns:
  /// - The result of the operation if it succeeds
  /// - Throws an exception if the operation fails after all attempts
  Future<void> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        await operation();
        return;
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(delay);
      }
    }
  }

  // Optional helper method for error messages
  String getErrorMessage(Object error) {
    if (error is NetworkException) {
      return 'Please check your internet connection';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'The operation timed out';
    }
    return 'An unexpected error occurred';
  }
}
