import 'package:bloc_small/bloc_small.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'count_cubit.freezed.dart';
part 'count_state.dart';

@injectable
class CountCubit extends MainCubit<CountState> {
  CountCubit() : super(CountState.initial());

  Future<void> increment() async {
    await cubitCatch(
      actions: () async {
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(count: state.count + 1));
      },
      keyLoading: 'increment',
    );
  }

  void decrement() {
    if (state.count > 0) {
      emit(state.copyWith(count: state.count - 1));
    }
  }
}
