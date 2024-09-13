import 'package:bloc_small/base/base_bloc.dart';
import 'package:bloc_small/base/base_bloc_event.dart';
import 'package:bloc_small/base/base_bloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'count_bloc.freezed.dart';
part 'count_event.dart';
part 'count_state.dart';

@injectable
class CountBloc extends BaseBloc<CountEvent, CountState> {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrementCounter);
    on<Decrement>(_onDecrementCounter);
  }

  void _onIncrementCounter(Increment event, Emitter<CountState> emit) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onDecrementCounter(Decrement event, Emitter<CountState> emit) {
    if (state.count > 0) emit(state.copyWith(count: state.count - 1));
  }
}