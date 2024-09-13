import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_small/base/base_bloc.dart';
import 'package:bloc_small/base/base_bloc_event.dart';
import 'package:bloc_small/base/base_bloc_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_bloc.freezed.dart';
part 'common_event.dart';
part 'common_state.dart';

class CommonBloc extends BaseBloc<CommonEvent, CommonState> {
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
