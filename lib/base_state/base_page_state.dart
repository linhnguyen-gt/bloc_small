import 'dart:io';

import 'package:bloc_small/constant/default_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../core/main_bloc.dart';
import '../common/common_bloc.dart';

/// A base class for all StatefulWidget states in the application that use a Bloc.
///
/// This class extends [BasePageStateDelegate] and provides a foundation for creating
/// state classes that are associated with a specific Bloc.
///
/// Type Parameters:
/// - [T]: The type of the StatefulWidget this state is associated with.
/// - [B]: The type of Bloc this state will use. Must extend [MainBloc].
///
/// Usage:
/// ```dart
/// class MyPageState extends BasePageState<MyPage, MyBloc> {
///   MyPageState(GetIt getIt) : super(getIt);
///
///   @override
///   Widget buildPage(BuildContext context) {
///     // Implement your page build logic here
///   }
/// }
/// ```
abstract class BasePageState<T extends StatefulWidget, B extends MainBloc>
    extends BasePageStateDelegate<T, B> {
  BasePageState(GetIt getIt) : super(getIt: getIt);
}

abstract class BasePageStateDelegate<T extends StatefulWidget,
    B extends MainBloc> extends State<T> {
  late final CommonBloc commonBloc;
  late final B bloc;

  final GetIt getIt;

  BasePageStateDelegate({required this.getIt});

  @override
  void initState() {
    super.initState();
    commonBloc = getIt.get<CommonBloc>();
    bloc = getIt.get<B>();
    bloc.commonBloc = commonBloc;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<B>(create: (_) => bloc),
        BlocProvider<CommonBloc>(create: (_) => commonBloc)
      ],
      child: buildPageListeners(
          child: Stack(
        children: [buildPage(context)],
      )),
    );
  }

  /// Wraps a child widget with a loading overlay that can be shown or hidden based on a loading state.
  ///
  /// This method uses a BlocBuilder with CommonBloc to reactively show or hide a loading overlay
  /// based on the loading state for a specific key.
  ///
  /// Parameters:
  /// - [child]: The main content widget to be displayed.
  /// - [loadingKey]: A unique identifier for the loading state. Defaults to [LoadingKeys.global].
  /// - [loadingWidget]: An optional custom widget to show when loading. If not provided, it uses the default loading indicator.
  ///
  /// The method creates a stack with the child widget and an animated loading overlay.
  /// The overlay's visibility is controlled by the loading state in CommonBloc.
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Widget buildPage(BuildContext context) {
  ///   return buildLoadingOverlay(
  ///     child: YourPageContent(),
  ///     loadingKey: LoadingKeys.global, // Optional, this is the default
  ///     loadingWidget: CustomLoadingWidget(), // Optional
  ///   );
  /// }
  /// ```
  ///
  /// Note: Ensure that CommonBloc is available in the widget tree and that loading states
  /// are properly managed using the specified loadingKey.
  Widget buildLoadingOverlay(
      {required Widget child,
      String? loadingKey = LoadingKeys.global,
      Widget? loadingWidget}) {
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

  Widget buildPage(BuildContext context);

  Widget buildPageListeners({required Widget child}) => child;

  Widget buildPageLoading() => const Center(child: LoadingIndicator());

  @override
  void dispose() {
    super.dispose();
  }
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
