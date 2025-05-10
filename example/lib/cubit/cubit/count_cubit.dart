import 'package:bloc_small/bloc_small.dart';

part 'count_cubit.freezed.dart';
part 'count_state.dart';

@injectable
class CountCubit extends MainCubit<CountState> with CubitErrorHandlerMixin {
  CountCubit() : super(CountState.initial());

  Future<void> increment() async {
    await cubitCatch(
      actions: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (state.count > 5) {
          throw Exception('Count cannot exceed 5');
        }
        emit(state.copyWith(count: state.count + 1));
      },
      keyLoading: 'increment',
      onError: handleError,
    );
  }

  void decrement() {
    if (state.count > 0) {
      emit(state.copyWith(count: state.count - 1));
    }
  }
}
