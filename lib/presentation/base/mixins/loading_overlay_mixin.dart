import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/default_loading.dart';
import '../../bloc/common_bloc.dart';
import '../../widgets/loading_indicator.dart';

/// A mixin that provides loading overlay functionality for base page classes.
///
/// This mixin extracts the common loading overlay logic that was duplicated
/// across [BaseBlocPageState], [BaseBlocPage], [BaseCubitPageState], and [BaseCubitPage].
///
/// The mixin provides:
/// - [buildLoadingOverlay] - Wraps widgets with a loading indicator overlay
/// - [buildPageLoading] - Builds the loading indicator widget
/// - [hideLoading] - Hides the loading overlay for a specific key
///
/// Requirements:
/// - The class using this mixin must have a [commonBloc] property of type [CommonBloc]
mixin LoadingOverlayMixin {
  /// The common bloc instance for managing loading states.
  CommonBloc get commonBloc;

  /// Hides the loading overlay for a specific key.
  ///
  /// [key] is a unique identifier for the loading state. If not provided, it defaults to [LoadingKey.global].
  void hideLoading({String? key = LoadingKey.global}) {
    commonBloc.add(
      SetComponentLoading(key: key ?? LoadingKey.global, isLoading: false),
    );
  }

  /// Builds the loading overlay widget using BlocBuilder.
  ///
  /// This is a helper method that can be called from [buildLoadingOverlay] implementations.
  /// It handles the BlocBuilder logic and timeout management.
  ///
  /// Parameters:
  /// - [child]: The widget to wrap with the loading overlay
  /// - [loadingKey]: Optional key to manage multiple loading states (defaults to global)
  /// - [loadingWidget]: Optional custom loading indicator widget
  /// - [timeout]: Optional duration after which loading will automatically hide (defaults to 30 seconds)
  ///
  /// Note: The context for mounted checks comes from the BlocBuilder's builder callback.
  Widget buildLoadingOverlayWidget({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen: (previous, current) =>
          previous.isLoading(key: loadingKey) !=
          current.isLoading(key: loadingKey),
      builder: (context, state) {
        if (state.isLoading(key: loadingKey)) {
          Future.delayed(timeout, () {
            if (context.mounted && state.isLoading(key: loadingKey)) {
              hideLoading(key: loadingKey);
            }
          });
        }
        return Stack(
          children: [
            child,
            if (state.isLoading(key: loadingKey))
              AnimatedOpacity(
                opacity: state.isLoading(key: loadingKey) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: loadingWidget ?? buildPageLoading(),
              ),
          ],
        );
      },
    );
  }

  /// Builds the loading indicator widget.
  ///
  /// Override this method to provide a custom loading indicator.
  Widget buildPageLoading() => const Center(child: LoadingIndicator());
}
