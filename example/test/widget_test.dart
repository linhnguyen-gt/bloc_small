import 'package:bloc_small_example/di/di.dart';
import 'package:bloc_small_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    configureInjectionApp();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // Smoke test: the example boots end to end against the real DI setup, which
  // is what catches a registration mistake in `configureInjectionApp` —
  // including a bloc registered as a factory, which base pages reject.
  testWidgets('the example app boots and renders its initial route', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
