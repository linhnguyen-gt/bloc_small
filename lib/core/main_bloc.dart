import 'dart:developer' as developer;

import 'package:bloc_small/constant/default_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/common_bloc.dart';
import 'main_bloc_event.dart';
import 'main_bloc_state.dart';

/// A base class for all Blocs in the application.
///
/// This class extends [BaseBlocDelegate] and provides a foundation for creating Blocs
/// with specific event and state types.
///
/// Type Parameters:
/// - [E]: The type of events this Bloc will handle. Must extend [MainBlocEvent].
/// - [S]: The type of states this Bloc will emit. Must extend [MainBlocState].
///
/// Usage:
/// ```dart
/// class MyBloc extends MainBloc<MyEvent, MyState> {
///   MyBloc() : super(MyInitialState());
///
/// }
/// ```
abstract class MainBloc<E extends MainBlocEvent, S extends MainBlocState>
    extends BaseBlocDelegate<E, S> {
  MainBloc(super.initialState);
}

abstract class BaseBlocDelegate<E extends MainBlocEvent,
    S extends MainBlocState> extends Bloc<E, S> {
  BaseBlocDelegate(super.initialState);

  late final CommonBloc _commonBloc;

  set commonBloc(CommonBloc commonBloc) {
    _commonBloc = commonBloc;
  }

  CommonBloc get commonBloc =>
      this is CommonBloc ? this as CommonBloc : _commonBloc;

  @override
  void add(E event) {
    if (!isClosed) {
      super.add(event);
    }
  }

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
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(initialState);
  }

  /// Shows the loading overlay for a specific key.
  ///
  /// [key] is a unique identifier for the loading state. If not provided, it defaults to [LoadingKeys.global].
  ///
  /// This method adds a [SetComponentLoading] event to the [commonBloc] to activate the loading state.
  ///
  /// Usage:
  /// ```dart
  /// void someMethodThatNeedsLoading() {
  ///   showLoading(key: LoadingKeys.global); // Or use a specific key
  ///   try {
  ///     // Do some work
  ///   } finally {
  ///     hideLoading(key: LoadingKeys.global); // Make sure to use the same key
  ///   }
  /// }
  /// ```
  void showLoading({String? key = LoadingKeys.global}) {
    commonBloc.add(SetComponentLoading(key: key!, isLoading: true));
  }

  /// Hides the loading overlay for a specific key.
  ///
  /// [key] is a unique identifier for the loading state. If not provided, it defaults to [LoadingKeys.global].
  ///
  /// This method adds a [SetComponentLoading] event to the [commonBloc] to deactivate the loading state.
  ///
  /// Usage:
  /// ```dart
  /// void someMethodThatNeedsLoading() {
  ///   showLoading(key: LoadingKeys.global); // Or use a specific key
  ///   try {
  ///     // Do some work
  ///   } finally {
  ///     hideLoading(key: LoadingKeys.global); // Make sure to use the same key
  ///   }
  /// }
  /// ```
  void hideLoading({String? key = LoadingKeys.global}) {
    commonBloc.add(SetComponentLoading(key: key!, isLoading: false));
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
  /// await blocCatch(
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
  Future<void> blocCatch({
    required Future<void> Function() actions,
    bool isLoading = true,
    String keyLoading = LoadingKeys.global,
    Future<void> Function(Object error, StackTrace stackTrace)? onError,
    Future<void> Function()? onFinally,
  }) async {
    try {
      if (isLoading) {
        showLoading(key: keyLoading);
      }
      await actions.call();
    } catch (e, stackTrace) {
      if (onError != null) {
        await onError(e, stackTrace);
      } else {
        developer.log('Error occurred: $e',
            name: 'Error', error: e, stackTrace: stackTrace);
      }
    } finally {
      if (isLoading) {
        hideLoading(key: keyLoading);
      }
      if (onFinally != null) {
        await onFinally();
      }
    }
  }
}
