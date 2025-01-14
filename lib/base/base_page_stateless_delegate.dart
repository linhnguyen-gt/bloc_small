import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/common/common_bloc.dart';
import '../constant/default_loading.dart';
import '../navigation/app_navigator.dart';
import '../widgets/loading_indicator.dart';

/// A base delegate class for StatelessWidget that use either Bloc or Cubit.
///
/// This class provides common functionality for state management and dependency injection.
///
/// Type Parameters:
/// - [B]: The type of state manager (Bloc or Cubit) this delegate will use.
///
/// The delegate handles:
/// - Dependency injection setup
/// - Common bloc integration
/// - Navigation setup
/// - Loading overlay management
abstract class BasePageStatelessDelegate<
    B extends StateStreamableSource<Object?>> extends StatelessWidget {
  BasePageStatelessDelegate({super.key});

  GetIt get di => GetIt.I;

  AppNavigator? get navigator =>
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

  /// Builds the main content of the page.
  Widget buildPage(BuildContext context);

  /// Builds any additional bloc listeners.
  Widget buildPageListeners({required Widget child}) => child;

  Widget buildLoadingOverlay({
    required Widget child,
    String? loadingKey = LoadingKey.global,
    Widget? loadingWidget,
  });

  /// Builds the loading indicator widget.
  Widget buildPageLoading() => const Center(child: LoadingIndicator());
}
