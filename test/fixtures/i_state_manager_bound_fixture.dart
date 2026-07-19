// Compile-failure fixture. This file is NOT meant to analyze cleanly — it
// exists so `test/fixtures/analyze_fixtures_test.dart` can assert that the
// analyzer rejects it. Excluded from the normal analysis run via
// analysis_options.yaml.
//
// It pins the I16 guarantee: a state manager that does not implement
// IStateManager cannot be used as a base page's `B`. Before IStateManager, the
// delegate reached the same wiring through `di<B>() as dynamic`, so this
// mistake compiled and failed at runtime instead.

import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

class PlainState {
  const PlainState();
}

/// A Cubit that deliberately does not extend MainCubit, so it does not
/// implement IStateManager.
class NotAStateManager extends Cubit<PlainState> {
  NotAStateManager() : super(const PlainState());
}

/// Expected analyzer error: 'NotAStateManager' doesn't conform to the bound
/// 'IStateManager<Object?>' of the type parameter 'B'.
///
/// Targets [BasePageStatelessDelegate] rather than `BaseBlocPage`, because the
/// latter narrows `B` to `MainBloc` and would reject this for that reason
/// instead — which would leave the IStateManager bound itself untested.
class BadPage extends BasePageStatelessDelegate<NotAStateManager> {
  const BadPage({super.key});

  @override
  Widget buildPage(BuildContext context, NotAStateManager stateManager) =>
      const SizedBox.shrink();

  @override
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey,
    Widget? loadingWidget,
  }) => child;
}
