import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant/default_loading.dart';
import '../core/bloc/main_bloc.dart';
import '../core/main_bloc_event.dart';
import '../core/main_bloc_state.dart';

part 'common_event.dart';
part 'common_state.dart';

class CommonBloc extends MainBloc<CommonEvent, CommonState> {
  CommonBloc() : super(const CommonState()) {
    on<SetComponentLoading>(_onSetComponentLoading);
  }

  FutureOr<void> _onSetComponentLoading(
      SetComponentLoading event, Emitter<CommonState> emit) {
    final updatedLoadingStates = Map<String, bool>.from(state.loadingStates);
    updatedLoadingStates[event.key] = event.isLoading;
    emit(state.copyWith(loadingStates: updatedLoadingStates));
  }
}
