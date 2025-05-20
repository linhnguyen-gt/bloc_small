import 'dart:io';

import 'package:bloc_small/presentation/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('should show appropriate indicator based on platform', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      // Check for the correct indicator based on the current platform
      if (Platform.isIOS) {
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      } else {
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      }
    });

    testWidgets('should apply custom background color', (
      WidgetTester tester,
    ) async {
      const customColor = Colors.amber;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(backgroundColor: customColor)),
        ),
      );

      // Find the Container that has the background color
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(customColor));
    });
  });
}
