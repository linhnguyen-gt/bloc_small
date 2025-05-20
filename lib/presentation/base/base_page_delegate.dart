import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/default_loading.dart';
import '../../navigation/app_navigator.dart';
import '../bloc/common_bloc.dart';

/// A base delegate class for StatefulWidget states that use either Bloc or Cubit.
///
/// This class provides common functionality for state management and dependency injection.
///
/// Type Parameters:
/// - [T]: The type of the StatefulWidget this state is associated with.
/// - [B]: The type of state manager (Bloc or Cubit) this delegate will use.
///
/// The delegate handles:
/// - Dependency injection setup
/// - Common bloc integration
/// - Navigation setup
/// - Loading overlay management
///
/// Required methods to implement:
/// - [buildPage]: Main page content
/// - [buildPageListeners]: Additional bloc listeners
/// - [buildLoadingOverlay]: Loading indicator overlay
/// - [buildPageLoading]: Loading indicator widget
abstract class BasePageDelegate<
  T extends StatefulWidget,
  B extends StateStreamableSource<Object?>
>
    extends State<T> {
  GetIt get di => GetIt.I;

  late final AppNavigator? navigator =
      di.isRegistered<AppNavigator>() ? di<AppNavigator>() : null;

  late final CommonBloc commonBloc = di<CommonBloc>()..navigator = navigator;

  /// The state manager instance for this page, automatically initialized with dependencies.
  ///
  /// This property provides access to the state management object that can be either
  /// a Bloc (for event-driven state management) or a Cubit (for direct method calls).
  ///
  /// In subclasses:
  /// - [BaseBlocPageState] provides a typed `bloc` getter that returns this as the correct Bloc type
  /// - [BaseCubitPageState] provides a typed `cubit` getter that returns this as the correct Cubit type
  ///
  /// Example usage:
  /// ```dart
  /// // In BaseBlocPageState subclasses, use the bloc getter:
  /// bloc.add(CounterEvent.increment());
  ///
  /// // In BaseCubitPageState subclasses, use the cubit getter:
  /// cubit.increment();
  /// ```
  ///
  /// The state manager is automatically disposed when the page is disposed.
  late final B stateManager =
      di<B>() as dynamic
        ..commonBloc = commonBloc
        ..navigator = navigator;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<B>(create: (_) => stateManager),
        BlocProvider<CommonBloc>(create: (_) => commonBloc),
      ],
      child: buildPageListeners(child: Stack(children: [buildPage(context)])),
    );
  }

  /// Builds the main content of the page.
  ///
  /// This method must be implemented by all pages to define their UI structure.
  /// It's called by the base delegate's [build] method and wrapped with necessary
  /// providers and listeners.
  ///
  /// Parameters:
  /// - [context]: The build context for this widget
  ///
  /// Example usage with BLoC:
  /// ```dart
  /// @override
  /// Widget buildPage(BuildContext context) {
  ///   return Scaffold(
  ///     appBar: AppBar(title: Text('My Page')),
  ///     body: BlocBuilder<MyBloc, MyState>(
  ///       builder: (context, state) {
  ///         return Column(
  ///           children: [
  ///             Text('Counter: ${state.count}'),
  ///             ElevatedButton(
  ///               onPressed: () => bloc.add(CounterEvent.increment()),
  ///               child: Text('Increment'),
  ///             ),
  ///           ],
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// Example usage with Cubit:
  /// ```dart
  /// @override
  /// Widget buildPage(BuildContext context) {
  ///   return Scaffold(
  ///     appBar: AppBar(title: Text('My Page')),
  ///     body: BlocBuilder<MyCubit, MyState>(
  ///       builder: (context, state) {
  ///         return Column(
  ///           children: [
  ///             Text('Counter: ${state.count}'),
  ///             ElevatedButton(
  ///               onPressed: () => bloc.increment(),
  ///               child: Text('Increment'),
  ///             ),
  ///           ],
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// Best Practices:
  /// - Wrap with [buildLoadingOverlay] if loading states are needed
  /// - Use [BlocBuilder] or [BlocConsumer] for reactive UI updates
  /// - Access bloc instance via the [bloc] property
  /// - Keep the UI logic separate from business logic
  Widget buildPage(BuildContext context);
  Widget buildPageListeners({required Widget child});

  /// Wraps a widget with a loading overlay that can be shown/hidden based on loading state.
  ///
  /// Parameters:
  /// - [child]: The widget to wrap with the loading overlay
  /// - [loadingKey]: Optional key to manage multiple loading states (defaults to global)
  /// - [loadingWidget]: Optional custom loading indicator widget
  ///
  /// The loading state is managed by [CommonBloc] and can be controlled using:
  /// ```dart
  /// // Show loading
  /// bloc.showLoading(key: 'customKey');
  ///
  /// // Hide loading
  /// bloc.hideLoading(key: 'customKey');
  /// ```
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// Widget buildPage(BuildContext context) {
  ///   return buildLoadingOverlay(
  ///     child: Scaffold(
  ///       body: YourContent(),
  ///     ),
  ///     loadingKey: 'customKey',
  ///     loadingWidget: CustomLoadingIndicator(),
  ///   );
  /// }
  /// ```
  ///
  /// Features:
  /// - Animated opacity transitions
  /// - Support for multiple loading states
  /// - Custom loading indicator support
  /// - Efficient rebuilds using buildWhen
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  });
  Widget buildPageLoading();
}
