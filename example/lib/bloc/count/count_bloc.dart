import 'package:bloc_small/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'count_bloc.freezed.dart';
part 'count_event.dart';
part 'count_state.dart';

@injectable
class CountBloc extends MainBloc<CountEvent, CountState> {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrementCounter);
    on<Decrement>(_onDecrementCounter);
  }

  Future<void> _onIncrementCounter(
      Increment event, Emitter<CountState> emit) async {
    await blocCatch(actions: () async {
      await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(count: state.count + 1));
    });
  }

  void _onDecrementCounter(Decrement event, Emitter<CountState> emit) {
    if (state.count > 0) emit(state.copyWith(count: state.count - 1));
  }
}
