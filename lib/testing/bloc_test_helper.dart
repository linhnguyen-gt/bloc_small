// lib/testing/bloc_test_helper.dart
import 'package:bloc_test/bloc_test.dart';

import '../bloc_small.dart';

abstract class BlocTestHelper<B extends MainBloc<E, S>, E extends MainBlocEvent,
    S extends MainBlocState> {
  B createBloc();

  void runBlocTest(
    String description, {
    required B Function() build,
    required List<E> acts,
    required List<S> expects,
    void Function(B)? verify,
  }) {
    blocTest<B, S>(
      description,
      build: build,
      act: (bloc) async {
        for (final event in acts) {
          bloc.add(event);
        }
      },
      expect: () => expects,
      verify: verify,
    );
  }
}
