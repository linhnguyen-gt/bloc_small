import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/default_loading.dart';
import '../bloc/common_bloc.dart';
import '../bloc/main_bloc.dart';
import '../widgets/loading_indicator.dart';
import 'base_page_stateless_delegate.dart';

/// A base class for all stateless widget pages in the application that use a Bloc.
///
/// This class extends [BasePageStatelessDelegate] and provides a foundation for creating
/// stateless widget pages that are associated with a specific Bloc.
///
/// Type Parameters:
/// - [B]: The type of Bloc this page will use. Must extend [MainBloc].
///
/// Features:
/// - Built-in loading state management via [CommonBloc]
/// - Automatic dependency injection using GetIt
/// - Navigation support via [AppNavigator]
/// - Built-in loading overlay with timeout
/// - Automatic lifecycle management
///
/// The class manages:
/// - Loading indicator display and hiding
/// - Common bloc integration
/// - Navigation setup
/// - Dependency injection
///
/// Usage example:
/// ```dart
/// class MyHomePage extends BaseBlocPage<MyBloc> {
///   const MyHomePage({super.key});
///
///   @override
///   Widget buildPage(BuildContext context) {
///     return buildLoadingOverlay(
///       child: Scaffold(
///         appBar: AppBar(title: const Text('My Page')),
///         body: BlocBuilder<MyBloc, MyState>(
///           builder: (context, state) {
///             return Text('${state.someData}');
///           },
///         ),
///         floatingActionButton: FloatingActionButton(
///           onPressed: () => bloc.add(const MyEvent()),
///           child: const Icon(Icons.add),
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// This approach provides a clean and consistent way to create stateless widget pages
/// with bloc integration, with all the necessary functionality inherited from the base class.
abstract class BaseBlocPage<B extends MainBloc>
    extends BasePageStatelessDelegate<B> {
  BaseBlocPage({super.key});

  /// Access the stateManager as a Bloc with the correct type.
  ///
  /// This property provides strongly-typed access to the state manager as a Bloc,
  /// allowing for event-based state management usage with the add() method.
  B get bloc => stateManager;

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
