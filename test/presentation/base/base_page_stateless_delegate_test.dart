import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_di_harness.dart';
import '../../support/test_pages.dart';

/// Rebuilds its child on demand so a stateless page can be observed across a
/// parent rebuild — the trigger for C7.
class Rebuilder extends StatefulWidget {
  final Widget Function() builder;

  const Rebuilder({required this.builder, super.key});

  @override
  State<Rebuilder> createState() => RebuilderState();
}

class RebuilderState extends State<Rebuilder> {
  @override
  Widget build(BuildContext context) => widget.builder();

  void rebuild() => setState(() {});
}

void main() {
  useCleanGetIt();

  group('BasePageStatelessDelegate — singleton-registered bloc', () {
    setUp(() {
      registerCoreAnd<TestBloc>(RegistrationStyle.singleton, TestBloc.new);
    });

    testWidgets('the tree provides the bloc GetIt owns', (tester) async {
      await tester.pumpWidget(wrapForTest(const TestStatelessBlocPage()));
      await tester.pumpAndSettle();

      final providedBloc = tester
          .element(find.byType(BlocBuilder<TestBloc, TestState>))
          .read<TestBloc>();

      expect(identical(providedBloc, GetIt.I<TestBloc>()), isTrue);
    });

    // C6 for the stateless twin: BlocProvider(create:) closes what GetIt owns.
    testWidgets('C6: bloc survives stateless page disposal', (tester) async {
      await tester.pumpWidget(wrapForTest(const TestStatelessBlocPage()));
      await tester.pumpAndSettle();

      final bloc = GetIt.I<TestBloc>();

      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));

      expect(bloc.isClosed, isFalse);

      bloc.add(const Increment());
      await tester.pumpAndSettle();
      expect(bloc.state.count, equals(1));
    });

    testWidgets('C3: stateless page push → dispose → push again works', (
      tester,
    ) async {
      await tester.pumpWidget(wrapForTest(const TestStatelessBlocPage()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(wrapForTest(const TestStatelessBlocPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('BasePageStatelessDelegate — buildPage wiring (C7)', () {
    late int resolutions;

    setUp(() {
      resolutions = 0;
      GetIt.I.registerCore();
      GetIt.I.registerLazySingleton<TestBloc>(() {
        resolutions++;
        return TestBloc();
      });
    });

    // The state manager is constructed once, not once per page widget.
    //
    // NOTE ON C7 COVERAGE — read before adding assertions here.
    //
    // C7 (the page driving a different instance than it renders) has **no
    // behavioral regression test**, and cannot have one under any supported
    // configuration. It only ever manifested when two resolutions of `B`
    // returned different objects, i.e. factory registration — which D6 now
    // rejects outright. Under a singleton, re-resolving per build and caching
    // in the State are indistinguishable: both yield the same object.
    //
    // Verified by mutation: changing `buildPage(context, stateManager)` back to
    // `buildPage(context, di<B>())` — C7's exact mechanism — leaves the whole
    // suite green. Counting factory invocations does not help either; GetIt
    // calls a lazySingleton's factory once regardless.
    //
    // What actually closes C7 is therefore structural, and each half is pinned
    // where it *is* observable:
    //   1. `buildPage(context, stateManager)` — the State passes the same
    //      object it provides to the tree, so they cannot diverge by
    //      construction (compile-time, not testable at runtime).
    //   2. factory registration rejected — the D6 group in
    //      `base_page_delegate_test.dart`, which does kill its mutant.
    //
    // The tests below are smoke checks of the wiring, not C7 regression tests.
    // Do not let a green run here be read as C7 coverage.
    testWidgets('the state manager is constructed once across rebuilds', (
      tester,
    ) async {
      final key = GlobalKey<RebuilderState>();
      final received = <TestBloc>[];

      await tester.pumpWidget(
        wrapForTest(
          Rebuilder(
            key: key,
            builder: () => RecordingStatelessBlocPage(received: received),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        key.currentState!.rebuild();
        await tester.pumpAndSettle();
      }

      expect(
        received.length,
        greaterThan(1),
        reason: 'the page must actually have rebuilt for this to prove anything',
      );
      expect(
        resolutions,
        equals(1),
        reason: 'the singleton must not be constructed again per page widget',
      );
    });

    testWidgets('buildPage receives the bloc the tree provides, across rebuilds', (
      tester,
    ) async {
      final key = GlobalKey<RebuilderState>();
      final received = <TestBloc>[];

      await tester.pumpWidget(
        wrapForTest(
          Rebuilder(
            key: key,
            builder: () => RecordingStatelessBlocPage(received: received),
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.rebuild();
      await tester.pumpAndSettle();

      final providedBloc = tester
          .element(find.byType(BlocBuilder<TestBloc, TestState>))
          .read<TestBloc>();

      expect(received, isNotEmpty);
      expect(
        received.every((b) => identical(b, providedBloc)),
        isTrue,
        reason:
            'the page drives the bloc it is handed; if that differs from what '
            'the tree provides, events go to an instance nothing displays',
      );
    });

    testWidgets('events sent to the handed bloc reach the rendered bloc', (
      tester,
    ) async {
      final key = GlobalKey<RebuilderState>();
      final received = <TestBloc>[];

      await tester.pumpWidget(
        wrapForTest(
          Rebuilder(
            key: key,
            builder: () => RecordingStatelessBlocPage(received: received),
          ),
        ),
      );
      await tester.pumpAndSettle();

      key.currentState!.rebuild();
      await tester.pumpAndSettle();

      received.last.add(const Increment());
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
