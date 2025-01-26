import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constant/default_loading.dart';
import '../base_delegate.dart';
import '../main_bloc_event.dart';
import '../main_bloc_state.dart';

/// A base class for all Blocs in the application.
///
/// This class extends [BaseBlocDelegate] and provides a foundation for creating Blocs
/// with specific event and state types.
///
/// Type Parameters:
/// - [E]: The type of events this Bloc will handle. Must extend [MainBlocEvent].
/// - [S]: The type of states this Bloc will emit. Must extend [MainBlocState].
///
/// Features:
/// - Built-in loading state management via [CommonBloc]
/// - Navigation support via [AppNavigator]
/// - Error handling with [blocCatch]
///
/// Usage:
/// ```dart
/// class CounterBloc extends MainBloc<CounterEvent, CounterState> {
///   CounterBloc() : super(const CounterState.initial()) {
///     on<Increment>(_onIncrementCounter);
///     on<Decrement>(_onDecrementCounter);
///   }
///
///   Future<void> _onIncrementCounter(
///       Increment event, Emitter<CounterState> emit) async {
///     await blocCatch(
///       actions: () async {
///         await Future.delayed(Duration(seconds: 2));
///         emit(state.copyWith(count: state.count + 1));
///       },
///       keyLoading: 'increment',
///       onError: handleError,
///     );
///   }
///
///   void _onDecrementCounter(Decrement event, Emitter<CounterState> emit) {
///     if (state.count > 0) emit(state.copyWith(count: state.count - 1));
///   }
/// }
/// ```
abstract class MainBloc<E extends MainBlocEvent, S extends MainBlocState>
    extends BaseBlocDelegate<E, S> {
  MainBloc(super.initialState);

  void onDependenciesChanged() {}
  void onDeactivate() {}
}

abstract class BaseBlocDelegate<E extends MainBlocEvent,
    S extends MainBlocState> extends Bloc<E, S> with BaseDelegate<S> {
  BaseBlocDelegate(super.initialState);

  /// Adds an event to the bloc if it's not closed.
  ///
  /// Parameters:
  /// - [event]: The event to add to the bloc.
  ///
  /// Usage:
  /// ```dart
  /// bloc.add(IncrementPressed());
  /// ```
  @override
  void add(E event) {
    if (!isClosed) {
      super.add(event);
    }
  }

  /// Resets the bloc to its initial state.
  ///
  /// Parameters:
  /// - [initialState]: The state to reset the bloc to.
  ///
  /// Usage:
  /// ```dart
  /// void cleanUp() {
  ///   reset(const CounterState.initial());
  /// }
  /// ```
  void reset(S initialState) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(initialState);
  }

  /// Executes a given asynchronous action within a try-catch block, handling loading states.
  ///
  /// Parameters:
  /// - [actions]: The async operations to perform.
  /// - [isLoading]: Whether to show loading indicator. Defaults to true.
  /// - [keyLoading]: Unique key for the loading state. Defaults to global.
  /// - [onError]: Custom error handler.
  /// - [onFinally]: Callback executed after completion.
  ///
  /// Usage:
  /// ```dart
  /// Future<void> _onIncrementCounter(
  ///     Increment event, Emitter<CounterState> emit) async {
  ///   await blocCatch(
  ///     actions: () async {
  ///       await Future.delayed(Duration(seconds: 1));
  ///       emit(state.copyWith(count: state.count + 1));
  ///     },
  ///     keyLoading: 'increment',
  ///     onError: handleError,
  ///   );
  /// }
  /// ```
  Future<void> blocCatch({
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
