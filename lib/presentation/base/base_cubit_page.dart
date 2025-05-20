import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/default_loading.dart';
import '../bloc/common_bloc.dart';
import '../cubit/main_cubit.dart';
import '../widgets/loading_indicator.dart';
import 'base_page_stateless_delegate.dart';

/// A base class for all stateless widget pages in the application that use a Cubit.
///
/// This class extends [BasePageStatelessDelegate] and provides a foundation for creating
/// stateless widget pages that are associated with a specific Cubit.
///
/// Type Parameters:
/// - [C]: The type of Cubit this page will use. Must extend [MainCubit].
///
/// Features:
/// - Built-in loading state management via [CommonBloc]
/// - Automatic dependency injection using GetIt
/// - Navigation support via [AppNavigator]
/// - Built-in loading overlay with timeout
/// - Direct state management without events
///
/// The class manages:
/// - Loading indicator display and hiding
/// - Common bloc integration
/// - Navigation setup
/// - Dependency injection
///
/// Usage example:
/// ```dart
/// class MyCounterPage extends BaseCubitPage<CounterCubit> {
///   const MyCounterPage({super.key});
///
///   @override
///   Widget buildPage(BuildContext context) {
///     return buildLoadingOverlay(
///       child: Scaffold(
///         appBar: AppBar(title: const Text('Counter')),
///         body: BlocBuilder<CounterCubit, CounterState>(
///           builder: (context, state) {
///             return Text('${state.count}');
///           },
///         ),
///         floatingActionButton: Column(
///           mainAxisAlignment: MainAxisAlignment.end,
///           children: [
///             FloatingActionButton(
///               onPressed: () => cubit.increment(), // Direct method call
///               child: const Icon(Icons.add),
///             ),
///             const SizedBox(height: 16),
///             FloatingActionButton(
///               onPressed: () => cubit.decrement(), // Direct method call
///               child: const Icon(Icons.remove),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// Compared to [BaseBlocPage], this class:
/// 1. Uses direct method calls instead of events
/// 2. Generally requires less boilerplate code
/// 3. Is better suited for simple state changes
/// 4. Still provides all the same infrastructure for loading states and error handling
abstract class BaseCubitPage<C extends MainCubit>
    extends BasePageStatelessDelegate<C> {
  BaseCubitPage({super.key});

  /// Access the stateManager as a Cubit with the correct type.
  ///
  /// This property provides strongly-typed access to the state manager as a Cubit,
  /// allowing for direct method calls on the cubit instance.
  C get cubit => stateManager;

  void hideLoading({String? key = LoadingKey.global}) {
    commonBloc.add(
      SetComponentLoading(key: key ?? LoadingKey.global, isLoading: false),
    );
  }

  @override
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen:
          (previous, current) =>
              previous.isLoading(key: loadingKey) !=
              current.isLoading(key: loadingKey),
      builder: (context, state) {
        if (state.isLoading(key: loadingKey)) {
          Future.delayed(timeout, () {
            final currentContext = context;
            if (currentContext.mounted && state.isLoading(key: loadingKey)) {
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

  @override
  Widget buildPageLoading() => const Center(child: LoadingIndicator());

  @override
  Widget buildPageListeners({required Widget child}) => child;
}
