// example/test/my_bloc_test.dart
import 'package:bloc_small/bloc_small.dart';
import 'package:bloc_small_example/bloc/count/count_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CountBloc', () {
    late CountBloc bloc;
    late CommonBloc commonBloc;

    setUp(() {
      commonBloc = CommonBloc();
      bloc = CountBloc();
      bloc.commonBloc = commonBloc;
    });

    blocTest<CountBloc, CountState>(
      'emits [1] when incremented',
      build: () => bloc,
      act: (bloc) => bloc.add(Increment()),
      wait: const Duration(seconds: 3),
      expect: () => [CountState.initial().copyWith(count: 1)],
    );

    tearDown(() {
      bloc.close();
      commonBloc.close();
    });
  });
}
