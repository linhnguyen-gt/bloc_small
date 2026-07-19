import 'package:bloc_small/bloc_small.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_pages.dart';

void main() {
  late CommonBloc commonBloc;
  late TestBloc bloc;

  setUp(() {
    commonBloc = CommonBloc();
    bloc = TestBloc()..commonBloc = commonBloc;
  });

  tearDown(() async {
    await bloc.close();
    await commonBloc.close();
  });

  group('catch policy (I5)', () {
    test('I5: an Error propagates to the caller', () async {
      expect(
        () => bloc.blocCatch(
          actions: () async => throw StateError('a bug'),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('I5: an Exception is handled and does not propagate', () async {
      Object? seen;

      await bloc.blocCatch(
        actions: () async => throw const NetworkException(),
        onError: (error, _) async => seen = error,
      );

      expect(seen, isA<NetworkException>());
    });

    // The original criterion — "Error reaches the caller" — was vacuous on its
    // own: it would pass even if the `finally`'s hideLoading threw and replaced
    // the propagating error. Assert the loading count too.
    test('I5: loading returns to its pre-call state when an Error escapes', () async {
      await Future<void>.delayed(Duration.zero);
      final before = commonBloc.state.isLoading(key: 'op');

      await expectLater(
        bloc.blocCatch(
          actions: () async => throw StateError('a bug'),
          keyLoading: 'op',
        ),
        throwsA(isA<StateError>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(commonBloc.state.isLoading(key: 'op'), equals(before));
    });

    // Guards objection 5 permanently: handleError must not also hide loading,
    // or a failing op decrements a refcounted key twice for one increment.
    test('a failing op inside catchError nets zero loading change', () async {
      await Future<void>.delayed(Duration.zero);
      final before = Map<String, dynamic>.from(commonBloc.state.loadingStates);

      await bloc.blocCatch(
        actions: () async => throw const NetworkException(),
        keyLoading: 'fetch',
        onError: bloc.handleError,
      );
      await Future<void>.delayed(Duration.zero);

      expect(commonBloc.state.loadingStates, equals(before));
    });
  });

  group('retryOperation (I20)', () {
    test('I20: returns the operation result', () async {
      final result = await bloc.retryOperation(operation: () async => 42);

      expect(result, equals(42));
    });

    test('I20: does not retry on an Error', () async {
      var calls = 0;

      await expectLater(
        bloc.retryOperation(
          operation: () async {
            calls++;
            throw StateError('a bug');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 1),
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        calls,
        equals(1),
        reason: 'retrying a bug re-runs side effects the operation already had',
      );
    });

    test('I20: still retries on an Exception', () async {
      var calls = 0;

      final result = await bloc.retryOperation(
        operation: () async {
          calls++;
          if (calls < 3) {
            throw const NetworkException();
          }
          return 'ok';
        },
        maxAttempts: 3,
        delay: const Duration(milliseconds: 1),
      );

      expect(calls, equals(3));
      expect(result, equals('ok'));
    });
  });

  group('exception hierarchy (B5)', () {
    test('B5: domain exceptions share a catchable base', () {
      expect(const NetworkException(), isA<AppException>());
      expect(const ValidationException(), isA<AppException>());
      expect(const AppTimeoutException(), isA<AppException>());
    });

    test('B5: toString surfaces the message, not the instance', () {
      expect(
        const NetworkException('no route to host').toString(),
        contains('no route to host'),
      );
      expect(
        const NetworkException('no route to host').toString(),
        isNot(contains('Instance of')),
      );
    });

    test('B5: getErrorMessage uses an AppException message', () {
      expect(
        bloc.getErrorMessage(const ValidationException('email is required')),
        equals('email is required'),
      );
    });
  });
}
