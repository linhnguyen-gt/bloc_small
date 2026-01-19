import 'package:flutter/material.dart';

import '../../core/constants/default_loading.dart';
import '../bloc/main_bloc.dart';
import 'base_page_delegate.dart';
import 'mixins/loading_overlay_mixin.dart';

/// A base class for all StatefulWidget states in the application that use a Bloc.
///
/// This class extends [BasePageDelegate] and provides a foundation for creating
/// state classes that are associated with a specific Bloc.
///
/// Type Parameters:
/// - [T]: The type of the StatefulWidget this state is associated with.
/// - [B]: The type of Bloc this state will use. Must extend [MainBloc].
///
/// Usage:
/// ```dart
/// class MyHomePageState extends BaseBlocPageState<MyHomePage, MyBloc> {
///   @override
///   Widget buildPage(BuildContext context) {
///     return buildLoadingOverlay(
///       child: Scaffold(
///         appBar: AppBar(title: Text('My Page')),
///         body: BlocBuilder<MyBloc, MyState>(
///           builder: (context, state) {
///             return Text('${state.data}');
///           },
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// The [buildLoadingOverlay] method can be used to wrap any widget with a loading indicator:
/// ```dart
/// buildLoadingOverlay(
///   child: YourWidget(),
///   loadingKey: 'customKey', // Optional, defaults to global
/// )
/// ```
///
/// Access the bloc instance using the [bloc] property:
/// ```dart
/// FloatingActionButton(
///   onPressed: () => bloc.add(YourEvent()),
///   child: Icon(Icons.add),
/// )
/// ```
abstract class BaseBlocPageState<T extends StatefulWidget, B extends MainBloc>
    extends BasePageDelegate<T, B> with LoadingOverlayMixin {
  /// Access the stateManager as a Bloc with the correct type.
  ///
  /// This property provides strongly-typed access to the state manager as a Bloc,
  /// allowing for event-based state management usage with the add() method.
  B get bloc => stateManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc.onDependenciesChanged();
  }

  @override
  void deactivate() {
    bloc.onDeactivate();
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
