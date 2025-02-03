import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bloc_small.dart';

abstract class BlocTestHelper<B extends MainBloc<E, S>, E extends MainBlocEvent,
    S extends MainBlocState> {
  B createBloc();

  late final B bloc = createBloc();

  void runBlocTest(
    String description, {
    required B Function() build,
    required List<E> acts,
    required List<S> expects,
    void Function(B)? verify,
    Duration? wait,
    dynamic Function()? expect,
  }) {
    blocTest<B, S>(
      description,
      build: build,
      act: (bloc) async {
        for (final event in acts) {
          bloc.add(event);
          if (wait != null) {
            await Future.delayed(wait);
          }
        }
      },
      expect: expects.isEmpty ? null : () => expects,
      verify: verify,
    );
  }

  B createMockedBloc({
    CommonBloc? mockCommonBloc,
    AppNavigator? mockNavigator,
  });

  Future<void> expectStateSequence(List<S> states, {Duration? timeout}) {
    var index = 0;
    final completer = Completer<void>();

    bloc.stream.listen(
      (state) {
        try {
          expect(state, states[index]);
          index++;
          if (index == states.length) {
            completer.complete();
          }
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: completer.completeError,
    );

    return completer.future.timeout(
      timeout ?? const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException(
        'State sequence did not complete within timeout',
      ),
    );
  }

  Future<void> expectError(Type errorType, {Duration? timeout}) {
    final completer = Completer<void>();

    bloc.stream.listen(
      null,
      onError: (error) {
        if (error.runtimeType == errorType) {
          completer.complete();
        } else {
          completer.completeError(
            'Expected error of type $errorType but got ${error.runtimeType}',
          );
        }
      },
    );

    return completer.future.timeout(
      timeout ?? const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException(
        'Error was not emitted within timeout',
      ),
    );
  }
}
