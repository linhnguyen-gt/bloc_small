// Compile-success fixture, checked by `analyze_fixtures_test.dart`.
//
// Pins I18: importing this package alongside the packages it used to re-export
// wholesale must not produce ambiguity errors.
//
// The collision actually observed while writing this release's tests was
// `injectable`'s `test` annotation against `flutter_test`'s `test` function —
// any test file importing both failed to compile with `ambiguous_import`, and
// two suites needed `hide test` to work around it. Restoring the `injectable`
// re-export makes this file fail, so it is a real regression gate.
//
// `provider` is imported too, because `flutter_bloc` re-exports it and the
// original rationale for trimming cited `ReadContext` ambiguity. That specific
// clash does not reproduce against the currently pinned versions — this import
// guards against it returning, it does not demonstrate it today.
//
// This file must analyze CLEANLY.

import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Touches names from every library in play.
Widget buildWithBoth(BuildContext context) {
  final fromProvider = Provider.of<String>(context, listen: false);
  final viaExtension = context.read<String>();
  final loading = const CommonState().isLoading();

  return Text('$fromProvider$viaExtension$loading');
}

/// `test` must unambiguously resolve to `flutter_test`'s function.
void usesTestFunction() {
  test('resolves without a hide clause', () {
    expect(const CommonState().isLoading(), isFalse);
  });
}
