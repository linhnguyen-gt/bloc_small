import 'dart:io';

import 'package:bloc_small/constant/default_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/common/common_bloc.dart';
import '../bloc/core/bloc/main_bloc.dart';
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
/// class MyHomePageState extends BasePageState<MyHomePage, MyBloc> {
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
abstract class BasePageState<T extends StatefulWidget, B extends MainBloc>
    extends BasePageDelegate<T, B> {
  @override
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  }) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen: (previous, current) =>
          previous.isLoading(loadingKey!) != current.isLoading(loadingKey),
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isLoading(loadingKey!))
              AnimatedOpacity(
                opacity: state.isLoading(loadingKey) ? 1.0 : 0.0,
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

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.backgroundColor = Colors.white12});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator()
            : const CircularProgressIndicator(),
      ),
    );
  }
}
