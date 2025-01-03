import 'dart:developer' as developer;
import 'dart:io';

import 'package:bloc_small/bloc/core/error/error_state.dart';
import 'package:bloc_small/bloc/core/main_bloc_state.dart';
import 'package:bloc_small/constant/default_loading.dart';
import 'package:bloc_small/navigation/app_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/common/common_bloc.dart';
import '../bloc/core/main_bloc.dart';

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
/// class MyHomePageState extends BasePageState<MyHomePage, CountBloc> {
///   MyHomePageState() : super();
///
///   @override
///   CountBloc createBloc() => CountBloc();
///
///   @override
///   Widget buildPage(BuildContext context) {
///     return buildLoadingOverlay(
///       child: Scaffold(
///         appBar: AppBar(title: Text('My Page')),
///         body: Center(
///           child: BlocBuilder<CountBloc, CountState>(
///             builder: (context, state) {
///               return Text('${state.count}');
///             },
///           ),
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
    extends BasePageStateDelegate<T, B> {
  BasePageState() : super();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

abstract class BasePageStateDelegate<T extends StatefulWidget,
    B extends MainBloc> extends State<T> {
  GetIt get di => GetIt.I;
  late final AppNavigator? navigator =
      di.isRegistered<AppNavigator>() ? di<AppNavigator>() : null;
  late final CommonBloc commonBloc = di<CommonBloc>()..navigator = navigator;

  late final B bloc = di<B>()
    ..commonBloc = commonBloc
    ..navigator = navigator;

  BasePageStateDelegate() : super();

  @override
  void initState() {
    super.initState();
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
      String? loadingKey = LoadingKey.global,
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

  Widget buildPageListeners({required Widget child}) {
    return BlocListener<B, MainBlocState>(
      listener: (context, state) {
        if (state is ErrorState) {
          final errorState = state;
          handleError(errorState.error, errorState.stackTrace);
        }
      },
      child: child,
    );
  }

  Widget buildPageLoading() => const Center(child: LoadingIndicator());

  @override
  void dispose() {
    super.dispose();
  }

  void handleError(Object error, StackTrace stackTrace) {
    developer.log('Error in ${T.toString()}',
        error: error, stackTrace: stackTrace);
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
