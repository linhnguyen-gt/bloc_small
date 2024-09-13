import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/common_bloc.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

/// A base class for all Blocs in the application.
///
/// This class extends [BaseBlocDelegate] and provides a foundation for creating Blocs
/// with specific event and state types.
///
/// Type Parameters:
/// - [E]: The type of events this Bloc will handle. Must extend [BaseBlocEvent].
/// - [S]: The type of states this Bloc will emit. Must extend [BaseBlocState].
///
/// Usage:
/// ```dart
/// class MyBloc extends BaseBloc<MyEvent, MyState> {
///   MyBloc() : super(MyInitialState());
///
/// }
/// ```
abstract class BaseBloc<E extends BaseBlocEvent, S extends BaseBlocState>
    extends BaseBlocDelegate<E, S> {
  BaseBloc(super.initialState);
}

abstract class BaseBlocDelegate<E extends BaseBlocEvent,
    S extends BaseBlocState> extends Bloc<E, S> {
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
  /// [key] is a unique identifier for the loading state.
  ///
  /// Usage:
  /// ```dart
  /// void someMethodThatNeedsLoading() {
  ///   showLoading(key: 'your_loading_key');
  ///   // Do some work
  ///   hideLoading(key: 'your_loading_key');
  /// }
  /// ```
  void showLoading({String? key = 'global'}) {
    commonBloc.add(SetComponentLoading(key: key!, isLoading: true));
  }

  /// Hides the loading overlay for a specific key.
  ///
  /// [key] is a unique identifier for the loading state.
  ///
  /// Usage:
  /// ```dart
  /// void someMethodThatNeedsLoading() {
  ///   showLoading(key: 'your_loading_key');
  ///   // Do some work
  ///   hideLoading(key: 'your_loading_key');
  /// }
  /// ```
  void hideLoading({String? key = 'global'}) {
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
  Future<void> blocCatch(
      {required Future<void> Function() actions,
      bool? isLoading = true}) async {
    try {
      if (isLoading!) {
        showLoading();
      }
      await actions.call();
      if (isLoading) {
        hideLoading();
      }
    } catch (e) {
      if (isLoading!) {
        hideLoading();
      }
      developer.log('$e', name: 'Error');
    }
  }
}
