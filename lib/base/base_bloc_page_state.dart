import 'package:bloc_small/constant/default_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/common/common_bloc.dart';
import '../bloc/core/bloc/main_bloc.dart';
import '../widgets/loading_indicator.dart';
import 'base_page_delegate.dart';

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
    extends BasePageDelegate<T, B> {
  @override
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  }) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen: (previous, current) =>
          previous.isLoading(key: loadingKey) !=
          current.isLoading(key: loadingKey),
      builder: (context, state) {
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
