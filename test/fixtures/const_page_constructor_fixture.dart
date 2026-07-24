// Compile-success fixture, checked by `analyze_fixtures_test.dart`.
//
// Pins B10: the `const MyHomePage({super.key})` form the docs always showed but
// which never compiled, because `BasePageStatelessDelegate` was a
// StatelessWidget carrying mutable `late final` dependency fields. Now that
// those live on the State, subclasses can be const again.
//
// This file must analyze CLEANLY — it is the inverse of
// `i_state_manager_bound_fixture.dart`.

import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

class CounterState extends MainBlocState {
  final int count;

  const CounterState({this.count = 0});
}

class CounterEvent extends MainBlocEvent {
  const CounterEvent();
}

class CounterBloc extends MainBloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState());
}

class CounterCubit extends MainCubit<CounterState> {
  CounterCubit() : super(const CounterState());
}

/// The documented const form, for a Bloc page.
class ConstBlocPage extends BaseBlocPage<CounterBloc> {
  const ConstBlocPage({super.key});

  @override
  Widget buildPage(BuildContext context, CounterBloc bloc) {
    return buildLoadingOverlay(child: const SizedBox.shrink());
  }
}

/// The documented const form, for a Cubit page.
class ConstCubitPage extends BaseCubitPage<CounterCubit> {
  const ConstCubitPage({super.key});

  @override
  Widget buildPage(BuildContext context, CounterCubit cubit) {
    return buildLoadingOverlay(child: const SizedBox.shrink());
  }
}

/// Const instantiation must be a compile-time constant expression.
const List<Widget> constPages = <Widget>[ConstBlocPage(), ConstCubitPage()];
