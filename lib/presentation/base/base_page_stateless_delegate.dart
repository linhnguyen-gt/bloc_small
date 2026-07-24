import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/default_loading.dart';
import '../../navigation/i_navigator.dart';
import '../bloc/common_bloc.dart';
import '../widgets/loading_indicator.dart';
import 'i_state_manager.dart';

/// A base page for widgets that use either a Bloc or a Cubit and hold no state
/// of their own beyond the injected state manager.
///
/// Type Parameters:
/// - [B]: The type of state manager (Bloc or Cubit) this page will use.
///
/// The delegate handles:
/// - Dependency injection setup
/// - Common bloc integration
/// - Navigation setup
/// - Loading overlay management
///
/// ## This is a StatefulWidget
///
/// It was previously a `StatelessWidget` carrying `late final` fields for its
/// resolved dependencies. That is unsound: Flutter may reconstruct a widget on
/// any parent rebuild, and the new instance resolves its own `stateManager`
/// while the element tree keeps providing the one built for the element — so
/// `bloc.add(...)` sent events to an instance nothing rendered. Resolution now
/// lives in the [State], which is what actually persists across rebuilds.
///
/// [buildPage] receives the state manager as an argument rather than reading a
/// field, so what a page renders and what it sends events to cannot diverge.
/// Subclasses may also declare `const` constructors again.
abstract class BasePageStatelessDelegate<B extends IStateManager<Object?>>
    extends StatefulWidget {
  const BasePageStatelessDelegate({super.key});

  /// Builds the main content of the page.
  ///
  /// [stateManager] is the instance this page provides to the widget tree —
  /// the same object `context.read<B>()` returns from anywhere below it.
  Widget buildPage(BuildContext context, B stateManager);

  /// Builds any additional bloc listeners.
  Widget buildPageListeners({required Widget child}) => child;

  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  });

  /// Builds the loading indicator widget.
  Widget buildPageLoading() => const Center(child: LoadingIndicator());

  @override
  State<BasePageStatelessDelegate<B>> createState() =>
      BasePageStatelessDelegateState<B>();
}

/// Holds the dependencies resolved for a [BasePageStatelessDelegate].
///
/// Everything here previously lived on the widget itself. It sits in the
/// [State] so it survives parent rebuilds and is resolved exactly once per
/// mounted page.
class BasePageStatelessDelegateState<B extends IStateManager<Object?>>
    extends State<BasePageStatelessDelegate<B>> {
  GetIt get di => GetIt.I;

  late final INavigator? navigator =
      di.isRegistered<INavigator>() ? di<INavigator>() : null;

  // No navigator wiring: CommonBloc is an app-wide singleton that only manages
  // loading state, and a per-page navigator on it would leak across pages.
  late final CommonBloc commonBloc = di<CommonBloc>();

  /// The state manager for this page, owned by the DI container.
  ///
  /// Not closed on page disposal — the container still hands it out.
  late final B stateManager = _resolveStateManager();

  B _resolveStateManager() {
    debugAssertSingletonRegistration<B>(di);
    return di<B>()
      ..commonBloc = commonBloc
      ..navigator = navigator;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // `.value`, not `create:` — the container owns these instances.
        BlocProvider<B>.value(value: stateManager),
        BlocProvider<CommonBloc>.value(value: commonBloc),
      ],
      child: widget.buildPageListeners(
        child: Stack(children: [widget.buildPage(context, stateManager)]),
      ),
    );
  }
}
