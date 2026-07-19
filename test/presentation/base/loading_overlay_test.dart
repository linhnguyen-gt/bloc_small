import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_di_harness.dart';
import '../../support/test_pages.dart';

void main() {
  useCleanGetIt();

  setUp(() {
    registerCoreAnd<TestBloc>(RegistrationStyle.singleton, TestBloc.new);
  });

  /// Pumps the page under test.
  ///
  /// Uses bounded `pump()` calls throughout this suite rather than
  /// `pumpAndSettle()`: the loading indicator is a `CircularProgressIndicator`,
  /// which animates indefinitely, so `pumpAndSettle` keeps advancing fake time
  /// until it passes the 30s safety timeout — which then fires and clears the
  /// very spinner the test is asserting on.
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(wrapForTest(const TestBlocPage()));
    await tester.pump();
  }

  /// Delivers a pending bloc event and rebuilds against the resulting state.
  ///
  /// One frame processes the event and emits; the next rebuilds the
  /// BlocBuilder. A single `pump()` leaves the tree a frame behind.
  Future<void> flush(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  group('overlay visibility', () {
    testWidgets('shows while a key is loading and hides when it clears', (
      tester,
    ) async {
      await pumpPage(tester);
      final bloc = GetIt.I<TestBloc>();

      expect(find.byType(LoadingIndicator), findsNothing);

      bloc.showLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsOneWidget);

      bloc.hideLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsNothing);
    });

    // I7 end-to-end: the spinner must outlast the first of two operations.
    testWidgets('I7: stays visible until the last overlapping op finishes', (
      tester,
    ) async {
      await pumpPage(tester);
      final bloc = GetIt.I<TestBloc>();

      bloc.showLoading();
      bloc.showLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsOneWidget);

      bloc.hideLoading();
      await flush(tester);
      expect(
        find.byType(LoadingIndicator),
        findsOneWidget,
        reason: 'one operation is still in flight',
      );

      bloc.hideLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsNothing);
    });

    // B9: the overlay never faded — it only existed while loading and its
    // opacity was hard-coded to 1.0.
    testWidgets('B9: no AnimatedOpacity in the overlay', (tester) async {
      await pumpPage(tester);
      GetIt.I<TestBloc>().showLoading();
      await flush(tester);

      expect(find.byType(AnimatedOpacity), findsNothing);
    });
  });

  group('safety timeout (I8)', () {
    testWidgets('force-clears a key still loading after the timeout', (
      tester,
    ) async {
      await pumpPage(tester);
      final bloc = GetIt.I<TestBloc>();

      // Two holders: a single decrement could not clear this.
      bloc.showLoading();
      bloc.showLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 31));
      await flush(tester);

      expect(
        find.byType(LoadingIndicator),
        findsNothing,
        reason: 'the escape hatch must work under refcounting, not just at 1',
      );
    });

    // The old timer captured `state` at build time, so its guard was trivially
    // true: a timer armed at t=0 fired at t=30s and killed whatever spinner was
    // showing, even one started at t=29s by a different operation.
    testWidgets('I8: a timeout armed by op A cannot hide op B spinner', (
      tester,
    ) async {
      await pumpPage(tester);
      final bloc = GetIt.I<TestBloc>();

      // Op A starts and finishes almost immediately.
      bloc.showLoading();
      await flush(tester);
      await tester.pump(const Duration(seconds: 1));
      bloc.hideLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsNothing);

      // Much later, an unrelated op B starts on the same key.
      await tester.pump(const Duration(seconds: 28));
      bloc.showLoading();
      await flush(tester);
      expect(find.byType(LoadingIndicator), findsOneWidget);

      // Op A's original 30s deadline passes. Op B has run for only 2s, so its
      // own deadline is still 28s away.
      await tester.pump(const Duration(seconds: 2));
      await flush(tester);

      expect(
        find.byType(LoadingIndicator),
        findsOneWidget,
        reason: "op A's stale timer must not dismiss op B's spinner",
      );

      bloc.hideLoading();
      await flush(tester);
    });

    testWidgets('no timer survives disposal', (tester) async {
      await pumpPage(tester);
      GetIt.I<TestBloc>().showLoading();
      await flush(tester);

      expect(debugActiveLoadingTimeoutTimers, greaterThan(0));

      await tester.pumpWidget(wrapForTest(const SizedBox.shrink()));
      await flush(tester);

      expect(
        debugActiveLoadingTimeoutTimers,
        equals(0),
        reason: 'a live timer retains the disposed page context',
      );
    });

    testWidgets('rebuilds do not accumulate timers', (tester) async {
      await pumpPage(tester);
      final bloc = GetIt.I<TestBloc>();

      bloc.showLoading();
      await flush(tester);
      final afterFirst = debugActiveLoadingTimeoutTimers;

      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(debugActiveLoadingTimeoutTimers, equals(afterFirst));

      bloc.hideLoading();
      await flush(tester);
      expect(debugActiveLoadingTimeoutTimers, equals(0));
    });
  });
}
