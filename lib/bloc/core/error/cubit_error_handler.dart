import 'dart:developer' as developer;

import '../cubit/main_cubit.dart';
import '../main_bloc_state.dart';

/// A mixin that provides error handling capabilities for Cubits.
///
/// This mixin can be used to add standardized error handling to any Cubit
/// that extends [MainCubit].
///
/// Usage:
/// ```dart
/// class MyCubit extends MainCubit<MyState> with CubitErrorHandler<MyState> {
///   MyCubit() : super(MyInitialState());
///
///   Future<void> someAction() async {
///     await cubitCatch(
///       actions: () async {
///         // Your logic here that might throw
///         throw Exception('Something went wrong');
///       },
///       onError: handleError,
///     );
///   }
///
///   // Optionally override handleError for custom handling
///   @override
///   Future<void> handleError(Object error, StackTrace stackTrace) async {
///     super.handleError(error, stackTrace);
///     emit(state.copyWith(error: error.toString()));
///   }
/// }
/// ```
mixin CubitErrorHandler<S extends MainBlocState> on MainCubit<S> {
  /// Handles errors that occur within the Cubit.
  ///
  /// By default, this method logs the error using the developer console.
  /// Override this method to provide custom error handling.
  Future<void> handleError(Object error, StackTrace stackTrace) async {
    developer.log('Cubit error occurred', error: error, stackTrace: stackTrace);
  }
}
