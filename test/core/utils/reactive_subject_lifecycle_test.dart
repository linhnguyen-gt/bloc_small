// Regression tests for the reactive_subject lifecycle rewrite (D4).
//
// These tests lock in child-owned subscription lifecycle: a derived subject
// cancels its upstream subscription in its own dispose(), and a parent's
// dispose() forwards onDone so the child closes too. They also prove, via a
// debug-only instance counter, that operators which used to allocate a
// throwaway ReactiveSubject per event (switchMap, onErrorResumeNext) no
// longer leak one per event.
import 'package:bloc_small/core/utils/reactive_subject/reactive_subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactiveSubject - Lifecycle', () {
    test(
      'child dispose cancels the upstream subscription: the mapper stops running',
      () async {
        final source = ReactiveSubject<int>(initialValue: 0);
        var mapCalls = 0;
        final mapped = source.map((i) {
          mapCalls++;
          return i * 2;
        });

        source.add(1);
        await Future.delayed(Duration.zero);
        expect(mapCalls, equals(2)); // initial value + add(1)

        await mapped.dispose();

        source.add(2);
        source.add(3);
        await Future.delayed(Duration.zero);

        // Once the child is disposed it must have cancelled its own
        // subscription to the source, so the mapper is never invoked again.
        expect(mapCalls, equals(2));

        await source.dispose();
      },
    );

    test(
      'parent dispose closes the child and forwards onDone to its listeners',
      () async {
        final source = ReactiveSubject<int>(initialValue: 0);
        final mapped = source.map((i) => i * 2);

        var childDone = false;
        mapped.stream.listen((_) {}, onDone: () => childDone = true);

        expect(mapped.isClosed, isFalse);

        await source.dispose();
        // Let the forwarded onDone/close propagate through the microtask queue.
        await Future.delayed(Duration.zero);

        expect(mapped.isClosed, isTrue);
        expect(childDone, isTrue);
      },
    );

    test(
      'switchMap does not leak a ReactiveSubject per event (instrumented counter)',
      () async {
        final baseline = ReactiveSubject.debugActiveInstanceCount;
        final source = ReactiveSubject<int>(initialValue: 0);

        final switched = source.switchMap(
          (i) => ReactiveSubject<String>(initialValue: 'value: $i'),
        );
        switched.stream.listen((_) {});

        for (var i = 1; i <= 1000; i++) {
          source.add(i);
        }
        await Future.delayed(Duration.zero);

        await switched.dispose();
        await source.dispose();

        // Every inner subject the mapper allocated (999 replaced + 1 final)
        // must have been disposed alongside `switched` and `source`
        // themselves, so the counter returns exactly to baseline.
        expect(ReactiveSubject.debugActiveInstanceCount, equals(baseline));
      },
    );

    test(
      'onErrorResumeNext does not leak a recovery ReactiveSubject per error',
      () async {
        final baseline = ReactiveSubject.debugActiveInstanceCount;
        final source = ReactiveSubject<int>();

        final recovered = source.onErrorResumeNext(
          (error) => ReactiveSubject<int>(initialValue: -1),
        );
        recovered.stream.listen((_) {}, onError: (_) {});

        for (var i = 0; i < 50; i++) {
          source.addError('error $i');
        }
        await Future.delayed(Duration.zero);

        await recovered.dispose();
        await source.dispose();

        expect(ReactiveSubject.debugActiveInstanceCount, equals(baseline));
      },
    );

    test('combineLatest forwards onDone when every source completes', () async {
      final a = ReactiveSubject<int>(initialValue: 1);
      final b = ReactiveSubject<int>(initialValue: 2);
      final combined = ReactiveSubject.combineLatest([a, b]);

      var done = false;
      combined.stream.listen((_) {}, onDone: () => done = true);

      await a.dispose();
      await b.dispose();
      await Future.delayed(Duration.zero);

      expect(combined.isClosed, isTrue);
      expect(done, isTrue);
    });

    test('merge forwards onDone when every source completes', () async {
      final a = ReactiveSubject<int>(initialValue: 1);
      final b = ReactiveSubject<int>(initialValue: 2);
      final merged = ReactiveSubject.merge([a, b]);

      var done = false;
      merged.stream.listen((_) {}, onDone: () => done = true);

      await a.dispose();
      await b.dispose();
      await Future.delayed(Duration.zero);

      expect(merged.isClosed, isTrue);
      expect(done, isTrue);
    });

    test('addError after dispose is silently ignored, not a crash', () async {
      final subject = ReactiveSubject<int>(initialValue: 0);
      await subject.dispose();

      // Before the fix, addError() had no disposal guard: it forwarded
      // straight to a closed Subject and threw.
      expect(() => subject.addError('late error'), returnsNormally);
    });

    test('sink.add routes through add(), respecting the dispose guard', () async {
      final subject = ReactiveSubject<int>(initialValue: 0);

      subject.sink.add(1);
      await Future.delayed(Duration.zero);
      expect(subject.value, equals(1));

      await subject.dispose();

      // Writing to sink after dispose must be a no-op, exactly like add(),
      // instead of bypassing the guard and crashing the closed subject.
      expect(() => subject.sink.add(2), returnsNormally);
    });
  });
}
