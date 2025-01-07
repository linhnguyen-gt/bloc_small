import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/common/common_bloc.dart';
import '../constant/default_loading.dart';
import '../navigation/app_navigator.dart';

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
abstract class BasePageDelegate<T extends StatefulWidget,
    B extends StateStreamableSource<Object?>> extends State<T> {
  GetIt get di => GetIt.I;

  late final AppNavigator? navigator =
      di.isRegistered<AppNavigator>() ? di<AppNavigator>() : null;

  late final CommonBloc commonBloc = di<CommonBloc>()..navigator = navigator;

  late final B bloc = di<B>() as dynamic
    ..commonBloc = commonBloc
    ..navigator = navigator;

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
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context);
  Widget buildPageListeners({required Widget child});
  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  });
  Widget buildPageLoading();
}
