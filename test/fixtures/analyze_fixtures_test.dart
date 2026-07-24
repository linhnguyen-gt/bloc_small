import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Asserts that the compile-failure fixtures in this directory are actually
/// rejected by the analyzer.
///
/// The `IStateManager` bound is a *compile-time* guarantee, so "a bloc that
/// does not implement it fails to compile" cannot be proven by a runtime test
/// or by reading the source — it needs a real analyzer run.
void main() {
  test(
    'I16: a state manager without IStateManager is rejected by the analyzer',
    () async {
      final result = await Process.run('dart', [
        'analyze',
        '--format',
        'json',
        'test/fixtures/i_state_manager_bound_fixture.dart',
      ], workingDirectory: Directory.current.path);

      expect(
        result.exitCode,
        isNot(0),
        reason:
            'the fixture must NOT analyze cleanly — if it does, the B bound no '
            'longer constrains anything and the I16 guarantee has regressed.\n'
            'stdout: ${result.stdout}\nstderr: ${result.stderr}',
      );

      final diagnostics = _diagnosticCodes(result.stdout.toString());
      expect(
        diagnostics,
        contains('type_argument_not_matching_bounds'),
        reason:
            'expected the bound violation specifically, not some unrelated '
            'error. Got: $diagnostics',
      );
    },
    // Spawning the analyzer is slow relative to a unit test.
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'I18: bloc_small coexists with flutter_test and provider',
    () async {
      final result = await Process.run('dart', [
        'analyze',
        '--format',
        'json',
        'test/fixtures/provider_coexistence_fixture.dart',
      ], workingDirectory: Directory.current.path);

      final errors = _diagnostics(
        result.stdout.toString(),
      ).where((d) => d['severity'] == 'ERROR').toList();

      expect(
        errors,
        isEmpty,
        reason:
            're-exporting a dependency wholesale reintroduces name collisions '
            'in consumer code. Errors: '
            '${errors.map((e) => e['problemMessage']).join(' | ')}',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'B10: the documented const page constructor compiles',
    () async {
      final result = await Process.run('dart', [
        'analyze',
        '--format',
        'json',
        'test/fixtures/const_page_constructor_fixture.dart',
      ], workingDirectory: Directory.current.path);

      final errors = _diagnostics(
        result.stdout.toString(),
      ).where((d) => d['severity'] == 'ERROR').toList();

      expect(
        errors,
        isEmpty,
        reason:
            'the const form the docs have always shown must actually compile.\n'
            'Errors: ${errors.map((e) => e['problemMessage']).join('\n')}',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

/// Extracts raw diagnostic objects from `dart analyze --format json` output.
List<Map<String, dynamic>> _diagnostics(String stdout) {
  for (final line in const LineSplitter().convert(stdout)) {
    if (!line.trimLeft().startsWith('{')) continue;
    try {
      final decoded = jsonDecode(line) as Map<String, dynamic>;
      final diagnostics = decoded['diagnostics'] as List<dynamic>?;
      if (diagnostics == null) continue;
      return diagnostics.cast<Map<String, dynamic>>();
    } on FormatException {
      continue;
    }
  }
  return const [];
}

/// Extracts diagnostic codes from `dart analyze --format json` output.
Set<String> _diagnosticCodes(String stdout) {
  for (final line in const LineSplitter().convert(stdout)) {
    if (!line.trimLeft().startsWith('{')) continue;
    try {
      final decoded = jsonDecode(line) as Map<String, dynamic>;
      final diagnostics = decoded['diagnostics'] as List<dynamic>?;
      if (diagnostics == null) continue;
      return diagnostics
          .map((d) => (d as Map<String, dynamic>)['code'] as String?)
          .whereType<String>()
          .toSet();
    } on FormatException {
      continue;
    }
  }
  return const {};
}
