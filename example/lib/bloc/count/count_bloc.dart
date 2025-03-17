import 'package:bloc_small/bloc_small.dart';
import 'package:injectable/injectable.dart';

part 'count_bloc.freezed.dart';
part 'count_event.dart';
part 'count_state.dart';

@injectable
class CountBloc extends MainBloc<CountEvent, CountState>
    with BlocErrorHandlerMixin {
  CountBloc() : super(const CountState.initial()) {
    on<Increment>(_onIncrementCounter);
    on<Decrement>(_onDecrementCounter);
  }

  Future<void> _onIncrementCounter(
      Increment event, Emitter<CountState> emit) async {
    await blocCatch(
        actions: () async {
          await Future.delayed(Duration(seconds: 2));
          if (state.count > 5) {
            throw Exception('Count cannot exceed 5');
          }
          emit(state.copyWith(count: state.count + 1));
        },
        onError: handleError);
  }

  void _onDecrementCounter(Decrement event, Emitter<CountState> emit) {
    if (state.count > 0) emit(state.copyWith(count: state.count - 1));
  }
}
