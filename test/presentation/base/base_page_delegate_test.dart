import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_di_harness.dart';
import '../../support/test_pages.dart';

void main() {
  useCleanGetIt();

  group('BasePageDelegate — singleton-registered bloc', () {
    setUp(() {
      registerCoreAnd<TestBloc>(RegistrationStyle.singleton, TestBloc.new);
    });

    // C6: BlocProvider(create:) makes the *widget* the owner, so popping the
    // page closes a bloc GetIt still hands out. Under D2 GetIt owns blocs and
    // widgets must use BlocProvider.value.
    testWidgets('C6: bloc survives page disposal', (tester) async {
      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      final bloc = GetIt.I<TestBloc>();
      expect(bloc.isClosed, isFalse);

      // Pop the page.
      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      // Bloc.close() awaits its event controller before the state controller,
      // so isClosed flips one async gap after disposal. Drain it, or this
      // assertion passes against a bloc that is already closing.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      expect(
        bloc.isClosed,
        isFalse,
        reason: 'GetIt owns the bloc; the widget must not close it',
      );

      // The property that actually matters: the bloc is still usable.
      bloc.add(const Increment());
      await tester.pumpAndSettle();
      expect(bloc.state.count, equals(1));
    });

    // C3: `late final WeakReference<CommonBloc> _commonBlocRef` can only be
    // assigned once. Re-pushing a page re-runs the delegate setter against the
    // same singleton bloc → LateInitializationError.
    testWidgets('C3: push → dispose → push again works', (tester) async {
      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();

      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('0'), findsOneWidget);
    });

    // C5: a bloc outliving its page still needs a usable commonBloc, or the
    // hideLoading() in catchError's `finally` throws and replaces the real error.
    testWidgets('C5: hideLoading after page disposal does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      final bloc = GetIt.I<TestBloc>();

      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(() => bloc.hideLoading(), returnsNormally);
    });

    testWidgets('the page renders the singleton bloc GetIt holds', (
      tester,
    ) async {
      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      GetIt.I<TestBloc>().add(const Increment());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('registration lifetime (D6)', () {
    // Factory registration cannot work for a page's state manager: pages
    // provide it with BlocProvider.value and never close it, and GetIt does
    // not track factory instances, so nothing would ever dispose them.
    testWidgets('a factory-registered bloc is rejected with a clear error', (
      tester,
    ) async {
      registerCoreAnd<TestBloc>(RegistrationStyle.factory, TestBloc.new);

      await tester.pumpWidget(wrapForTest(const TestBlocPage()));

      expect(
        tester.takeException(),
        isA<StateError>().having(
          (e) => e.message,
          'message',
          allOf(contains('factory'), contains('registerLazySingleton')),
        ),
      );
    });

    testWidgets('a lazySingleton-registered bloc is accepted', (tester) async {
      registerCoreAnd<TestBloc>(RegistrationStyle.singleton, TestBloc.new);

      await tester.pumpWidget(wrapForTest(const TestBlocPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('BasePageDelegate — cubit', () {
    setUp(() {
      registerCoreAnd<TestCubit>(RegistrationStyle.singleton, TestCubit.new);
    });

    testWidgets('C6: cubit survives page disposal', (tester) async {
      await tester.pumpWidget(wrapForTest(const TestCubitPage()));
      await tester.pumpAndSettle();

      final cubit = GetIt.I<TestCubit>();

      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      expect(cubit.isClosed, isFalse);

      cubit.increment();
      expect(cubit.state.count, equals(1));
    });

    testWidgets('C3: cubit page push → dispose → push again works', (
      tester,
    ) async {
      await tester.pumpWidget(wrapForTest(const TestCubitPage()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(wrapForTest(const TestCubitPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
