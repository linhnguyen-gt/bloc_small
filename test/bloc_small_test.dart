import 'package:bloc_small/bloc_small.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterEvent extends MainBlocEvent {
  const CounterEvent();
}

class CounterState extends MainBlocState {
  final int? count;

  const CounterState({this.count});

  dynamic get data => count;
}

class CounterBloc extends MainBloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState());

  Future<void> increment() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      emit(CounterState(count: (state.count ?? 0) + 1));
    } catch (error) {}
  }
}

void main() {
  group('BlocSmall Tests', () {
    late CounterBloc counterBloc;

    setUp(() {
      GetIt.I.reset();
      GetIt.I.registerSingleton<GetIt>(GetIt.instance);
      counterBloc = CounterBloc();
    });

    tearDown(() {
      counterBloc.close();
    });

    test('initial state is 0', () {
      expect(counterBloc.state.data, null);
    });

    blocTest<CounterBloc, CounterState>(
      'emits [1] when increment is called',
      build: () => counterBloc,
      act: (bloc) => bloc.increment(),
      expect: () => [
        predicate<CounterState>(
          (state) => state.data as int == 1,
        ),
      ],
    );

    blocTest<CounterBloc, CounterState>(
      'handles multiple increments',
      build: () => counterBloc,
      act: (bloc) async {
        await bloc.increment();
        await bloc.increment();
        await bloc.increment();
      },
      expect: () => [
        predicate<CounterState>((state) => state.data as int == 1),
        predicate<CounterState>((state) => state.data as int == 2),
        predicate<CounterState>((state) => state.data as int == 3),
      ],
    );
  });
}
