import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../base/base_bloc.dart';
import '../common/common_bloc.dart';

abstract class BasePageState<T extends StatefulWidget, B extends BaseBloc>
    extends BasePageStateDelegate<T, B> {
  BasePageState(GetIt getIt) : super(getIt: getIt);
}

abstract class BasePageStateDelegate<T extends StatefulWidget,
    B extends BaseBloc> extends State<T> {
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

  Widget buildLoadingOverlay(
      Widget child, String loadingKey, Widget? loadingWidget) {
    return BlocBuilder<CommonBloc, CommonState>(
      buildWhen: (previous, current) =>
          previous.isLoading(loadingKey) != current.isLoading(loadingKey),
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isLoading(loadingKey))
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
