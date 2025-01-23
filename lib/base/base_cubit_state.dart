import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/common/common_bloc.dart';
import '../bloc/core/cubit/main_cubit.dart';
import '../constant/default_loading.dart';
import '../widgets/loading_indicator.dart';
import 'base_page_delegate.dart';

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
    extends BasePageDelegate<T, C> {
  void hideLoading({String? key = LoadingKey.global}) {
    commonBloc.add(
        SetComponentLoading(key: key ?? LoadingKey.global, isLoading: false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    (bloc as MainCubit).onDependenciesChanged();
  }

  @override
  void deactivate() {
    (bloc as MainCubit).onDeactivate();
    super.deactivate();
  }

  @override
  Widget buildLoadingOverlay({
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
            if (mounted && state.isLoading(key: loadingKey))
              hideLoading(key: loadingKey);
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
