import 'package:flutter/material.dart';

import '../../core/constants/default_loading.dart';
import '../cubit/main_cubit.dart';
import 'base_page_delegate.dart';
import 'mixins/loading_overlay_mixin.dart';

/// A base class for all StatefulWidget states in the application that use a Cubit.
///
/// This class extends [BasePageDelegate] and provides a foundation for creating
/// state classes that are associated with a specific Cubit.
///
/// Type Parameters:
/// - [T]: The type of the StatefulWidget this state is associated with.
/// - [C]: The type of Cubit this state will use. Must extend [MainCubit].
///
/// Usage:
/// ```dart
/// class MyHomePageState extends BaseCubitPageState<MyHomePage, MyCubit> {
///   @override
///   Widget buildPage(BuildContext context) {
///     return buildLoadingOverlay(
///       child: Scaffold(
///         appBar: AppBar(title: Text('My Page')),
///         body: BlocBuilder<MyCubit, MyState>(
///           builder: (context, state) {
///             return Text('${state.data}');
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
abstract class BaseCubitPageState<T extends StatefulWidget, C extends MainCubit>
    extends BasePageDelegate<T, C>
    with LoadingOverlayMixin {
  /// Access the stateManager as a Cubit with the correct type.
  ///
  /// This property provides strongly-typed access to the state manager as a Cubit,
  /// allowing for direct method calls on the cubit instance.
  C get cubit => stateManager;

  // No `hideLoading` here, deliberately. Loading keys are refcounted, and this
  // class offered no matching `showLoading`, so calling it decremented a count
  // the page never incremented — dropping the spinner while the operation that
  // raised it was still running. `BaseBlocPageState` never had the method.
  // Hide loading from the cubit that showed it, via `cubitCatch`/`hideLoading`
  // on the delegate, so every decrement pairs with an increment.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cubit.onDependenciesChanged();
  }

  @override
  void deactivate() {
    cubit.onDeactivate();
    super.deactivate();
  }

  @override
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  }) {
    return buildLoadingOverlayWidget(
      child: child,
      loadingKey: loadingKey,
      loadingWidget: loadingWidget,
      timeout: const Duration(seconds: 30),
    );
  }

  @override
  Widget buildPageListeners({required Widget child}) => child;
}
