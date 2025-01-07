import 'dart:developer' as developer;

import '../bloc/main_bloc.dart';
import '../main_bloc_event.dart';
import '../main_bloc_state.dart';

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
mixin BlocErrorHandler<E extends MainBlocEvent, S extends MainBlocState>
    on MainBloc<E, S> {
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
    developer.log('Bloc error occurred', error: error, stackTrace: stackTrace);
  }
}
