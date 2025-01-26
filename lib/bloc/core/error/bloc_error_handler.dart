import 'dart:developer' as developer;

import '../bloc/main_bloc.dart';
import '../cubit/main_cubit.dart';
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

/// Base mixin containing shared error handling functionality.
/// This mixin defines the contract for error handling capabilities
/// that should be implemented by both Bloc and Cubit error handlers.
mixin BaseErrorHandlerMixin {
  /// Retries an operation until it succeeds or reaches the maximum number of attempts.
  ///
  /// Parameters:
  /// - [operation]: A function that returns a Future to be retried
  /// - [maxAttempts]: The maximum number of attempts to retry the operation (default: 3)
  /// - [delay]: The delay between attempts (default: 1 second)
  ///
  /// Returns:
  /// - The result of the operation if it succeeds
  /// - Throws the last error if all attempts fail
  Future<void> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  });

  /// Converts an error object into a user-friendly message.
  ///
  /// Handles common exceptions like:
  /// - [NetworkException]
  /// - [ValidationException]
  /// - [TimeoutException]
  ///
  /// Returns a localized error message string.
  String getErrorMessage(Object error);

  /// Hides any loading indicators or progress states.
  /// Should be implemented by the concrete class to handle UI state.
  void hideLoading();
}

/// A mixin that provides error handling capabilities for Blocs.
/// Implements [BaseErrorHandlerMixin] and adds specific Bloc error handling.
mixin BlocErrorHandlerMixin<Event extends MainBlocEvent,
        State extends MainBlocState> on MainBloc<Event, State>
    implements BaseErrorHandlerMixin {
  @override
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
        if (attempts == maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
  }

  @override
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
}

/// A mixin that provides error handling capabilities for Cubits.
/// Implements [BaseErrorHandlerMixin] and adds specific Cubit error handling.
mixin CubitErrorHandlerMixin<State extends MainBlocState> on MainCubit<State>
    implements BaseErrorHandlerMixin {
  @override
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
        if (attempts == maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
  }

  @override
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

  Future<void> handleError(Object error, StackTrace stackTrace) async {
    developer.log(
      'Cubit error occurred',
      error: error,
      name: runtimeType.toString(),
      time: DateTime.now(),
      level: 1000,
      stackTrace: stackTrace,
    );

    hideLoading();
  }
}
