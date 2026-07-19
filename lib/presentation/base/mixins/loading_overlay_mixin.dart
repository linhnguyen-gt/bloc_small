import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/default_loading.dart';
import '../../bloc/common_bloc.dart';
import '../../widgets/loading_indicator.dart';

/// Provides the loading overlay used by every base page class.
///
/// The mixin is deliberately **stateless**: it declares no instance fields, so
/// applying it to a widget still permits a `const` constructor. The safety
/// timeout needs mutable state, so it lives in [_LoadingOverlay]'s own `State`
/// — which is also what makes it cancel automatically when the overlay leaves
/// the tree, with nothing for page classes to remember to call.
///
/// It reads [CommonBloc] from the build context rather than from a field, so it
/// works on both a `State` and a `StatefulWidget`.
mixin LoadingOverlayMixin {
  /// Builds the loading overlay.
  ///
  /// Parameters:
  /// - [child]: The widget to wrap with the loading overlay
  /// - [loadingKey]: Optional key to manage multiple loading states
  /// - [loadingWidget]: Optional custom loading indicator widget
  /// - [timeout]: How long before a stuck spinner is force-cleared
  Widget buildLoadingOverlayWidget({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _LoadingOverlay(
      loadingKey: loadingKey ?? LoadingKey.global,
      loadingWidget: loadingWidget ?? buildPageLoading(),
      timeout: timeout,
      child: child,
    );
  }

  /// Builds the loading indicator widget.
  ///
  /// Override this method to provide a custom loading indicator.
  Widget buildPageLoading() => const Center(child: LoadingIndicator());
}

/// Shows [loadingWidget] over [child] while [loadingKey] is loading, and
/// force-clears the key if it stays loading longer than [timeout].
class _LoadingOverlay extends StatefulWidget {
  final Widget child;
  final Widget loadingWidget;
  final String loadingKey;
  final Duration timeout;

  const _LoadingOverlay({
    required this.child,
    required this.loadingWidget,
    required this.loadingKey,
    required this.timeout,
  });

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay> {
  /// Safety timer for this overlay's key only, so a timeout can never dismiss
  /// an operation other than the one that armed it.
  ///
  /// Previously each qualifying rebuild scheduled an uncancellable
  /// `Future.delayed` that closed over a stale `state`, making its
  /// `isLoading` guard trivially true. A timer armed by an operation that had
  /// long since finished would fire 30s later and dismiss whatever spinner
  /// happened to be showing.
  Timer? _timeoutTimer;

  /// Live safety timers across all overlays, for tests asserting that none
  /// survive disposal.
  @visibleForTesting
  static int debugActiveTimeoutTimers = 0;

  void _arm() {
    if (_timeoutTimer != null) {
      return; // Re-arming per rebuild would leak a timer per frame.
    }
    debugActiveTimeoutTimers++;
    _timeoutTimer = Timer(widget.timeout, () {
      _disarm();
      if (!mounted) {
        return;
      }
      final bloc = context.read<CommonBloc>();
      // Read the *current* state, not one captured at build time.
      if (bloc.state.isLoading(key: widget.loadingKey)) {
        // Force-clear rather than decrement: the key may be held by several
        // operations, and one decrement could not dismiss a stuck spinner.
        bloc.add(ClearComponentLoading(key: widget.loadingKey));
      }
    });
  }

  void _disarm() {
    if (_timeoutTimer == null) {
      return;
    }
    _timeoutTimer!.cancel();
    _timeoutTimer = null;
    debugActiveTimeoutTimers--;
  }

  @override
  void dispose() {
    // A live timer would retain this State and its context.
    _disarm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen: (previous, current) =>
          previous.isLoading(key: widget.loadingKey) !=
          current.isLoading(key: widget.loadingKey),
      builder: (context, state) {
        final isLoading = state.isLoading(key: widget.loadingKey);

        if (isLoading) {
          _arm();
        } else {
          _disarm();
        }

        return Stack(
          children: [
            widget.child,
            // No AnimatedOpacity: the overlay only existed while isLoading was
            // true and its opacity was hard-coded to 1.0, so it never animated
            // in either direction.
            if (isLoading) widget.loadingWidget,
          ],
        );
      },
    );
  }
}

/// Test-only view of live safety timers.
@visibleForTesting
int get debugActiveLoadingTimeoutTimers =>
    _LoadingOverlayState.debugActiveTimeoutTimers;
