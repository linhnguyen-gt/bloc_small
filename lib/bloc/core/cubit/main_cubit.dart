import 'package:bloc_small/constant/default_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../base_delegate.dart';
import '../main_bloc_state.dart';

/// A base class for all Cubits in the application.
///
/// This class extends [BaseCubitDelegate] and provides a foundation for creating Cubits
/// with specific state types.
///
/// Type Parameters:
/// - [S]: The type of states this Cubit will emit. Must extend [MainBlocState].
///
/// Features:
/// - Built-in loading state management via [CommonBloc]
/// - Navigation support via [AppNavigator]
/// - Error handling with [cubitCatch]
///
/// Usage:
/// ```dart
/// class CounterCubit extends MainCubit<CounterState> {
///   CounterCubit() : super(const CounterState.initial());
///
///   Future<void> increment() async {
///     await cubitCatch(
///       actions: () async {
///         await Future.delayed(Duration(seconds: 1));
///         emit(state.copyWith(count: state.count + 1));
///       },
///       keyLoading: 'increment',
///       onError: handleError,
///     );
///   }
///
///   void decrement() {
///     if (state.count > 0) {
///       emit(state.copyWith(count: state.count - 1));
///     }
///   }
/// }
/// ```
abstract class MainCubit<S extends MainBlocState> extends BaseCubitDelegate<S> {
  MainCubit(super.initialState);
}

abstract class BaseCubitDelegate<S extends MainBlocState> extends Cubit<S>
    with BaseDelegate<S> {
  BaseCubitDelegate(super.initialState);

  /// Resets the bloc to its initial state.
  ///
  /// [initialState] is the state to reset the bloc to.
  ///
  /// This method directly emits the initial state, bypassing the normal event-driven state changes.
  /// It's useful for resetting the bloc to a known state, typically when cleaning up or reinitializing.
  ///
  /// Note: This method uses a protected API and should be used cautiously.
  ///
  /// Usage:
  /// ```dart
  /// void cleanUpBloc() {
  ///   reset(MyInitialState());
  /// }
  /// ```
  void reset(S initialState) {
    emit(initialState);
  }

  /// Executes a given asynchronous action within a try-catch block, handling loading states.
  ///
  /// This method provides a convenient way to perform asynchronous operations while
  /// automatically managing loading states and error handling.
  ///
  /// Parameters:
  /// - [actions]: A required function that contains the asynchronous operations to be performed.
  /// - [isLoading]: An optional boolean that determines whether to show/hide loading indicators.
  ///   Defaults to true.
  ///
  /// Usage:
  /// ```dart
  /// await cubitCatch(
  ///   actions: () async {
  ///     // Perform some asynchronous operations
  ///     await fetchData();
  ///     await processData();
  ///   },
  ///   isLoading: true, // Optional, defaults to true
  /// );
  /// ```
  ///
  /// The method will:
  /// 1. Show a loading indicator if [isLoading] is true.
  /// 2. Execute the provided [actions].
  /// 3. Hide the loading indicator after [actions] complete or if an error occurs.
  /// 4. Log any errors that occur during execution.
  ///
  /// Note: This method uses [showLoading] and [hideLoading] internally, which should be
  /// implemented in the concrete Bloc class or a mixin.
  Future<void> cubitCatch({
    required Future<void> Function() actions,
    bool isLoading = true,
    String keyLoading = LoadingKey.global,
    Future<void> Function(Object error, StackTrace stackTrace)? onError,
    Future<void> Function()? onFinally,
  }) async {
    await catchError(
      actions: actions,
      isLoading: isLoading,
      keyLoading: keyLoading,
      onError: onError,
      onFinally: onFinally,
    );
  }
}
