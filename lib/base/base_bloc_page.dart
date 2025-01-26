import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/common/common_bloc.dart';
import '../bloc/core/bloc/main_bloc.dart';
import '../constant/default_loading.dart';
import '../widgets/loading_indicator.dart';
import 'base_page_stateless_delegate.dart';

abstract class BaseBlocPage<B extends MainBloc>
    extends BasePageStatelessDelegate<B> {
  BaseBlocPage({super.key});

  void hideLoading({String? key = LoadingKey.global}) {
    commonBloc.add(
        SetComponentLoading(key: key ?? LoadingKey.global, isLoading: false));
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
