import 'package:bloc_small/bloc_small.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_pages.dart';

void main() {
  group('BaseDelegate — commonBloc wiring', () {
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

    // C3: the setter is backed by `late final`, so assigning twice throws.
    // A singleton bloc re-wired by a second page hits exactly this.
    test('C3: assigning commonBloc twice is idempotent, not fatal', () {
      expect(() => bloc.commonBloc = commonBloc, returnsNormally);
    });

    test('reports a clear error when commonBloc was never wired', () {
      final orphan = TestBloc();
      addTearDown(orphan.close);

      // Must name the real cause, and must be a StateError rather than the
      // LateError that `late final` produces.
      expect(() => orphan.commonBloc, throwsA(isA<StateError>()));
    });

    // C5: a bloc outliving its page must still accept hideLoading(); the call
    // sits in catchError's `finally`, where a throw replaces the real error.
    test('C5: hideLoading works after the wiring page is gone', () {
      expect(() => bloc.hideLoading(), returnsNormally);
    });
  });

  group('reset() after close (I6)', () {
    test('I6: bloc reset after close does not throw', () async {
      final bloc = TestBloc()..commonBloc = CommonBloc();
      await bloc.close();

      expect(() => bloc.reset(const TestState()), returnsNormally);
    });

    test('I6: cubit reset after close does not throw', () async {
      final cubit = TestCubit()..commonBloc = CommonBloc();
      await cubit.close();

      expect(() => cubit.reset(const TestState()), returnsNormally);
    });
  });

  group('concurrent loading (I7)', () {
    late CommonBloc commonBloc;

    setUp(() => commonBloc = CommonBloc());
    tearDown(() => commonBloc.close());

    // I7: loadingStates is Map<String,bool>, so the first operation to finish
    // clears the spinner while the second is still running.
    test('I7: spinner stays up until the last operation on a key finishes', () async {
      final bloc = TestBloc()..commonBloc = commonBloc;
      addTearDown(bloc.close);

      bloc.showLoading(key: 'fetch');
      bloc.showLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);
      expect(commonBloc.state.isLoading(key: 'fetch'), isTrue);

      // First of the two operations completes.
      bloc.hideLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);
      expect(
        commonBloc.state.isLoading(key: 'fetch'),
        isTrue,
        reason: 'one operation is still in flight',
      );

      // Second completes.
      bloc.hideLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);
      expect(commonBloc.state.isLoading(key: 'fetch'), isFalse);
    });

    test('I7: keys are removed once they reach zero', () async {
      final bloc = TestBloc()..commonBloc = commonBloc;
      addTearDown(bloc.close);

      bloc.showLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);
      bloc.hideLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);

      expect(
        commonBloc.state.loadingStates.containsKey('fetch'),
        isFalse,
        reason: 'per-item keys otherwise leak an entry for the app lifetime',
      );
    });

    test('I7: hideLoading floors at zero', () async {
      final bloc = TestBloc()..commonBloc = commonBloc;
      addTearDown(bloc.close);

      bloc.hideLoading(key: 'fetch');
      bloc.showLoading(key: 'fetch');
      await Future<void>.delayed(Duration.zero);

      expect(commonBloc.state.isLoading(key: 'fetch'), isTrue);
    });
  });
}
