import 'dart:developer' as developer;

import 'package:bloc_small/constant/default_loading.dart';
import 'package:bloc_small/navigation/app_navigator.dart';

import '../common/common_bloc.dart';
import 'main_bloc_state.dart';

/// Base delegate containing shared functionality between Bloc and Cubit.
///
/// This mixin provides common functionality for state management, loading indicators,
/// and error handling that can be used by both Bloc and Cubit implementations.
///
/// Features:
/// - Loading state management via [showLoading] and [hideLoading]
/// - Navigation support via [navigator]
/// - Common bloc integration via [commonBloc]
/// - Error handling with [catchError]
///
/// Type Parameters:
/// - [S]: The type of states. Must extend [MainBlocState].
///
/// Usage with Bloc:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with BaseDelegate<MyState> {
///   Future<void> handleAsyncOperation() async {
///     await catchError(
///       actions: () async {
///         showLoading(key: 'myOperation');
///         await someAsyncWork();
///         hideLoading(key: 'myOperation');
///       },
///     );
///   }
/// }
/// ```
///
/// Usage with Cubit:
/// ```dart
/// class MyCubit extends Cubit<MyState> with BaseDelegate<MyState> {
///   Future<void> handleAsyncOperation() async {
///     await catchError(
///       actions: () async {
///         showLoading();
///         await someAsyncWork();
///         hideLoading();
///       },
///     );
///   }
/// }
/// ```
mixin BaseDelegate<S extends MainBlocState> {
  AppNavigator? navigator;
  late final CommonBloc _commonBloc;

  set commonBloc(CommonBloc commonBloc) {
    _commonBloc = commonBloc;
  }

  CommonBloc get commonBloc =>
      this is CommonBloc ? this as CommonBloc : _commonBloc;

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
  void showLoading({String? key = LoadingKey.global}) {
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
  void hideLoading({String? key = LoadingKey.global}) {
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
  Future<void> catchError({
    required Future<void> Function() actions,
    bool isLoading = true,
    String keyLoading = LoadingKey.global,
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
