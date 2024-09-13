import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/common_bloc.dart';
import 'base_bloc_event.dart';
import 'base_bloc_state.dart';

abstract class BaseBloc<E extends BaseBlocEvent, S extends BaseBlocState>
    extends BaseBlocDelegate<E, S> {
  BaseBloc(super.initialState);
}

abstract class BaseBlocDelegate<E extends BaseBlocEvent,
    S extends BaseBlocState> extends Bloc<E, S> {
  BaseBlocDelegate(super.initialState);

  late final CommonBloc _commonBloc;

  set commonBloc(CommonBloc commonBloc) {
    _commonBloc = commonBloc;
  }

  CommonBloc get commonBloc =>
      this is CommonBloc ? this as CommonBloc : _commonBloc;

  @override
  void add(E event) {
    if (!isClosed) {
      super.add(event);
    }
  }

  void reset(S initialState) {
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(initialState);
  }

  Future<void> blocCatch(
      {required Future<void> Function() actions,
      bool? isLoading = true}) async {
    try {
      await actions.call();
    } catch (e) {
      developer.log('$e', name: 'Error');
    }
  }
}
