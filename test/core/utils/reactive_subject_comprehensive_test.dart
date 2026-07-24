import 'dart:async';

import 'package:bloc_small/core/utils/reactive_subject/reactive_subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactiveSubject - Comprehensive Tests', () {
    late ReactiveSubject<int> subject;

    setUp(() {
      subject = ReactiveSubject<int>(initialValue: 0);
    });

    tearDown(() async {
      await subject.dispose();
    });

    group('Basic Operations', () {
      test('should create with initial value', () {
        expect(subject.value, equals(0));
        expect(subject.hasValue, isTrue);
      });

      test('should create without initial value', () async {
        final emptySubject = ReactiveSubject<int>();
        // A fresh subject holds no value; valueOrNull must report that
        // without throwing (C1).
        expect(emptySubject.hasValue, isFalse);
        expect(emptySubject.valueOrNull, isNull);
        await emptySubject.dispose();
      });

      test('valueOr should return default when no value', () async {
        final emptySubject = ReactiveSubject<int>();
        expect(emptySubject.valueOr(42), equals(42));
        emptySubject.add(10);
        await Future.delayed(Duration.zero);
        expect(emptySubject.valueOr(42), equals(10));
        await emptySubject.dispose();
      });

      test('should throw when accessing value without initial value', () async {
        final emptySubject = ReactiveSubject<int?>();
        // Must be a StateError, not a LateInitializationError: a LateError
        // here means `late T? _value` was never initialised (C1).
        expect(() => emptySubject.value, throwsA(isA<StateError>()));
        await emptySubject.dispose();
      });

      test(
        'a null value counts as a value, not as absence of one (I14)',
        () async {
          final nullableSubject = ReactiveSubject<String?>();
          expect(nullableSubject.hasValue, isFalse);

          nullableSubject.add(null);
          await Future.delayed(Duration.zero);

          // Before the fix, `hasValue`/`value` used `_value != null` as a
          // proxy for "has a value", so a legitimately-null value was
          // indistinguishable from "no value set" and `.value` threw.
          expect(nullableSubject.hasValue, isTrue);
          expect(nullableSubject.value, isNull);
          expect(nullableSubject.valueOrNull, isNull);

          await nullableSubject.dispose();
        },
      );

      test('should add and emit values', () async {
        final values = <int>[];
        subject.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);
        expect(values, equals([0, 1, 2, 3]));
      });

      test('should handle errors', () async {
        final errors = <Object>[];
        subject.stream.listen(null, onError: errors.add);

        subject.addError('test error');

        await Future.delayed(Duration.zero);
        expect(errors, contains('test error'));
      });
    });

    group('Disposal', () {
      test('should dispose correctly', () async {
        await subject.dispose();
        expect(subject.isDisposed, isTrue);
        expect(subject.isClosed, isTrue);
      });

      test('should silently ignore when adding to disposed subject', () async {
        final initialValue = subject.value;
        await subject.dispose();
        expect(subject.isDisposed, isTrue);
        // Should not throw - silently ignores to prevent errors from async operations
        expect(() => subject.add(1), returnsNormally);
        // Verify value was not added (value is cleared on dispose, so use valueOr)
        expect(subject.valueOr(initialValue), equals(initialValue));
      });

      test('should not dispose twice', () async {
        await subject.dispose();
        await subject.dispose(); // Should not throw
        expect(subject.isDisposed, isTrue);
      });
    });

    group('Transformation Methods', () {
      test('map should transform values', () async {
        final mapped = subject.map((i) => i * 2);
        final values = <int>[];
        mapped.stream.listen(values.add);

        subject.add(1);
        subject.add(2);

        await Future.delayed(Duration.zero);
        expect(values, equals([0, 2, 4]));
        await mapped.dispose();
      });

      test('where should filter values', () async {
        final filtered = subject.where((i) => i > 1);
        final values = <int>[];
        filtered.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);
        expect(values, equals([2, 3]));
        await filtered.dispose();
      });

      test('distinct should remove duplicates', () async {
        final distinct = subject.distinct();
        final values = <int>[];
        distinct.stream.listen(values.add);

        subject.add(1);
        subject.add(1);
        subject.add(2);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);
        expect(values, equals([0, 1, 2, 3]));
        await distinct.dispose();
      });

      test('distinctBy should filter by key', () async {
        final userSubject = ReactiveSubject<Map<String, dynamic>>();
        final distinct = userSubject.distinctBy((user) => user['id']);
        final values = <Map<String, dynamic>>[];
        distinct.stream.listen(values.add);

        userSubject.add({'id': 1, 'name': 'Alice'});
        userSubject.add({'id': 1, 'name': 'Alice Updated'});
        userSubject.add({'id': 2, 'name': 'Bob'});

        await Future.delayed(Duration.zero);
        expect(values.length, equals(2));
        expect(values[0]['id'], equals(1));
        expect(values[1]['id'], equals(2));

        await distinct.dispose();
        await userSubject.dispose();
      });

      test(
        'distinctBy is distinct-among-every-value-ever-seen, not distinct-until-changed (D12)',
        () async {
          final userSubject = ReactiveSubject<Map<String, dynamic>>();
          final distinct = userSubject.distinctBy((user) => user['id']);
          final values = <Map<String, dynamic>>[];
          distinct.stream.listen(values.add);

          userSubject.add({'id': 1, 'name': 'Alice'});
          userSubject.add({'id': 2, 'name': 'Bob'});
          // id 1 reappears after another key was seen in between: a true
          // distinct-until-changed operator would let this through (the
          // immediate predecessor has a different key), but this operator
          // remembers every key for the subject's lifetime, so it is
          // filtered out here too. D12: this is the confirmed, intentional
          // behavior — only the docs were wrong, not the code.
          userSubject.add({'id': 1, 'name': 'Alice Again'});

          await Future.delayed(Duration.zero);
          expect(values.length, equals(2));
          expect(values.map((u) => u['id']), equals(<int>[1, 2]));

          await distinct.dispose();
          await userSubject.dispose();
        },
      );
    });

    group('Time-based Operations', () {
      test('debounceTime should delay emissions', () async {
        final debounced = subject.debounceTime(
          const Duration(milliseconds: 100),
        );
        final values = <int>[];
        debounced.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(const Duration(milliseconds: 50));
        expect(values, isEmpty);

        await Future.delayed(const Duration(milliseconds: 100));
        // Debounce filters out rapid emissions, only last value passes
        expect(values, equals([3]));

        await debounced.dispose();
      });

      test('throttleTime should limit emissions', () async {
        final throttled = subject.throttleTime(
          const Duration(milliseconds: 100),
        );
        final values = <int>[];
        throttled.stream.listen(values.add);

        subject.add(1);
        await Future.delayed(const Duration(milliseconds: 10));
        subject.add(2);
        await Future.delayed(const Duration(milliseconds: 10));
        subject.add(3);

        await Future.delayed(const Duration(milliseconds: 150));
        expect(values.length, lessThanOrEqualTo(3));

        await throttled.dispose();
      });
    });

    group('Combination Methods', () {
      test('combineLatest should combine multiple subjects', () async {
        final subject1 = ReactiveSubject<int>(initialValue: 1);
        final subject2 = ReactiveSubject<int>(initialValue: 2);
        final combined = ReactiveSubject.combineLatest([subject1, subject2]);
        final values = <List<int>>[];
        combined.stream.listen(values.add);

        await Future.delayed(Duration.zero);
        expect(values.last, equals([1, 2]));

        subject1.add(3);
        await Future.delayed(Duration.zero);
        expect(values.last, equals([3, 2]));

        await combined.dispose();
        await subject1.dispose();
        await subject2.dispose();
      });

      test('merge should merge multiple subjects', () async {
        final subject1 = ReactiveSubject<int>(initialValue: 1);
        final subject2 = ReactiveSubject<int>(initialValue: 2);
        final merged = ReactiveSubject.merge([subject1, subject2]);
        final values = <int>[];
        merged.stream.listen(values.add);

        subject1.add(3);
        subject2.add(4);

        await Future.delayed(Duration.zero);
        expect(values, containsAll([1, 2, 3, 4]));

        await merged.dispose();
        await subject1.dispose();
        await subject2.dispose();
      });

      test('withLatestFrom should combine with latest value', () async {
        final subject1 = ReactiveSubject<int>(initialValue: 1);
        final subject2 = ReactiveSubject<String>(initialValue: 'a');
        final combined = subject1.withLatestFrom(
          subject2,
          (int a, String b) => '$a$b',
        );
        final values = <String>[];
        combined.stream.listen(values.add);

        await Future.delayed(Duration.zero);
        subject1.add(2);
        await Future.delayed(Duration.zero);

        expect(values, contains('2a'));

        await combined.dispose();
        await subject1.dispose();
        await subject2.dispose();
      });
    });

    group('Accumulation Methods', () {
      test('scan should accumulate values', () async {
        final scanned = subject.scan<int>(0, (acc, curr, index) => acc + curr);
        final values = <int>[];
        scanned.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);
        expect(values, equals([0, 1, 3, 6]));

        await scanned.dispose();
      });

      test('startWith should prepend value', () async {
        final started = subject.startWith(-1);
        final values = <int>[];
        started.stream.listen(values.add);

        await Future.delayed(Duration.zero);
        // Assert the full emission list: `values.first` passes even when the
        // seed is emitted twice, which is exactly what hides I10.
        expect(values, equals(<int>[-1, 0]));

        await started.dispose();
      });
    });

    group('Error Handling', () {
      test('onErrorResumeNext should recover from errors', () async {
        final recovered = subject.onErrorResumeNext(
          (error) => ReactiveSubject<int>(initialValue: 999),
        );
        final values = <int>[];
        recovered.stream.listen(values.add);

        subject.add(1);
        subject.addError('test error');

        await Future.delayed(Duration.zero);
        expect(values, contains(999));

        await recovered.dispose();
      });

      test(
        'retry() does not leak an orphan subject per attempt (I2 leak half of item 11)',
        () async {
          final baseline = ReactiveSubject.debugActiveInstanceCount;
          final testSubject = ReactiveSubject<int>();
          final retried = testSubject.retry(2);

          final errors = <Object>[];
          retried.stream.listen((_) {}, onError: errors.add);

          testSubject.addError('test error');
          await Future.delayed(const Duration(milliseconds: 100));

          await retried.dispose();
          await testSubject.dispose();

          // Before the fix, every retry attempt allocated a fresh
          // ReactiveSubject via a recursive `retry(count - 1)` call and
          // never disposed the ones it stopped using — the same per-event
          // leak class as switchMap/onErrorResumeNext.
          expect(ReactiveSubject.debugActiveInstanceCount, equals(baseline));
        },
      );

      test(
        'retry() cannot re-run work on a BehaviorSubject-backed source: '
        'it just replays the same cached error (documented limitation, item 11)',
        () async {
          // ReactiveSubject wraps a value stream, not a task factory. Its
          // default constructor is BehaviorSubject-backed, which replays
          // its most recently emitted item OR error to every new
          // subscriber. retry()'s only mechanism is "subscribe again", so
          // each retry attempt immediately re-receives the exact same
          // cached error instead of giving the source a chance to produce
          // a different outcome. This probe proves that determinism: with
          // count=2, retry re-subscribes exactly twice, replaying the same
          // error each time, then gives up — never anything else.
          final testSubject = ReactiveSubject<int>();
          final retried = testSubject.retry(2);

          final errors = <Object>[];
          retried.stream.listen((_) {}, onError: errors.add);

          testSubject.addError('boom');
          await Future.delayed(const Duration(milliseconds: 50));

          expect(errors, equals(<Object>['boom']));

          await retried.dispose();
          await testSubject.dispose();
        },
      );

    });

    group('Side Effects', () {
      test('doOnData should perform side effects', () async {
        final sideEffects = <int>[];
        final withSideEffect = subject.doOnData(sideEffects.add);
        final values = <int>[];
        withSideEffect.stream.listen(values.add);

        subject.add(1);
        subject.add(2);

        await Future.delayed(Duration.zero);
        expect(sideEffects, equals([0, 1, 2]));
        expect(values, equals([0, 1, 2]));

        await withSideEffect.dispose();
      });

      test('doOnError should handle errors', () async {
        final errors = <Object>[];
        final withErrorHandler = subject.doOnError(
          (error, stack) => errors.add(error),
        );
        withErrorHandler.stream.listen(null, onError: (_) {});

        subject.addError('test error');

        await Future.delayed(Duration.zero);
        expect(errors, contains('test error'));

        await withErrorHandler.dispose();
      });
    });

    group('Utility Methods', () {
      test('mapNotNull should filter null values', () async {
        final stringSubject = ReactiveSubject<String>();
        final mapped = stringSubject.mapNotNull((s) => int.tryParse(s));
        final values = <int>[];
        mapped.stream.listen(values.add);

        stringSubject.add('123');
        stringSubject.add('abc');
        stringSubject.add('456');

        await Future.delayed(Duration.zero);
        expect(values, equals([123, 456]));

        await mapped.dispose();
        await stringSubject.dispose();
      });

      test('whereNotNull should filter null values', () async {
        final nullableSubject = ReactiveSubject<int?>();
        final nonNull = nullableSubject.whereNotNull();
        final values = <int?>[];
        nonNull.stream.listen((value) => values.add(value));

        nullableSubject.add(1);
        nullableSubject.add(null);
        nullableSubject.add(2);

        await Future.delayed(Duration.zero);
        expect(values, equals([1, 2]));

        await nonNull.dispose();
        await nullableSubject.dispose();
      });

      test('pairwise should emit pairs', () async {
        final paired = subject.pairwise();
        final values = <List<int>>[];
        paired.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);
        expect(values.length, greaterThan(0));

        await paired.dispose();
      });
    });

    group('Buffer and Group', () {
      test('buffer should collect values', () async {
        final timer = Stream.periodic(
          const Duration(milliseconds: 100),
        ).take(2);
        final buffered = subject.buffer(timer);
        final values = <List<int>>[];

        final subscription = buffered.stream.listen(values.add);

        subject.add(1);
        subject.add(2);

        await Future.delayed(const Duration(milliseconds: 150));
        expect(values.isNotEmpty, isTrue);

        await subscription.cancel();
      });

      test('groupBy should group values by key', () async {
        final grouped = subject.groupBy(
          (value) => value % 2 == 0 ? 'even' : 'odd',
        );
        final values = <Map<String, List<int>>>[];
        grouped.stream.listen(values.add);

        subject.add(1);
        subject.add(2);
        subject.add(3);
        subject.add(4);

        await Future.delayed(Duration.zero);
        expect(values.isNotEmpty, isTrue);
        final lastGroup = values.last;
        expect(lastGroup.containsKey('even'), isTrue);
        expect(lastGroup.containsKey('odd'), isTrue);

        await grouped.dispose();
      });

      test(
        'a groupBy snapshot never changes after it was emitted (I11)',
        () async {
          final grouped = subject.groupBy(
            (value) => value % 2 == 0 ? 'even' : 'odd',
          );
          final values = <Map<String, List<int>>>[];
          grouped.stream.listen(values.add);

          subject.add(1);
          await Future.delayed(Duration.zero);
          // Snapshot right after the first odd value: must never grow later.
          final snapshotAfterFirst = values.last;
          final oddListAfterFirst = List<int>.of(snapshotAfterFirst['odd']!);

          subject.add(2);
          subject.add(3);
          await Future.delayed(Duration.zero);

          // Before the fix, `Map.from(groups)` was a shallow copy that still
          // shared its List values with every later emission, so this
          // already-delivered snapshot's 'odd' list grew from [1] to [1, 3]
          // after the fact.
          expect(snapshotAfterFirst['odd'], equals(oddListAfterFirst));
          expect(snapshotAfterFirst['odd'], equals(<int>[1]));

          await grouped.dispose();
        },
      );
    });

    group('Debug', () {
      test('debug should log values', () async {
        final debugValues = <int>[];
        final debugged = subject.debug(
          tag: 'TestStream',
          onValue: debugValues.add,
        );
        debugged.stream.listen((_) {});

        subject.add(1);
        subject.add(2);

        await Future.delayed(Duration.zero);
        expect(debugValues, equals([0, 1, 2]));

        await debugged.dispose();
      });
    });

    group('Share', () {
      test('share should share subscription', () async {
        final shared = subject.share();
        final values1 = <int>[];
        final values2 = <int>[];

        shared.stream.listen(values1.add);
        shared.stream.listen(values2.add);

        subject.add(1);

        await Future.delayed(Duration.zero);
        expect(values1, contains(1));
        expect(values2, contains(1));

        await shared.dispose();
      });

      test('shareReplay(maxSize: 2) replays the last 2 values, not 1 (I9)', () async {
        final shared = subject.shareReplay(maxSize: 2);

        subject.add(1);
        subject.add(2);
        subject.add(3);

        await Future.delayed(Duration.zero);

        final values = <int>[];
        shared.stream.listen(values.add);

        await Future.delayed(Duration.zero);
        // Before the fix, the result was always built on the default
        // BehaviorSubject-backed constructor, which can only replay 1
        // regardless of maxSize, so a late subscriber only ever saw [3].
        expect(values, equals(<int>[2, 3]));

        await shared.dispose();
      });
    });

    group('Cache', () {
      test(
        "cache()'s own docstring example works: a late subscriber gets the cached value immediately (C8)",
        () async {
          // Must be `.broadcast()` (PublishSubject-backed): the default
          // constructor is already BehaviorSubject-backed, so cache() takes
          // its "already caching" shortcut and returns `source` unchanged,
          // trivially passing without ever exercising cache()'s own logic.
          final source = ReactiveSubject<String>.broadcast();
          final cached = source.cache();

          source.add('hello');
          await Future.delayed(Duration.zero);

          final values = <String>[];
          // Subscribing after 'hello' was already added is the whole point:
          // a replaying subject must hand it to this late listener anyway.
          cached.stream.listen(values.add);
          await Future.delayed(Duration.zero);

          expect(values, equals(<String>['hello']));

          source.add('world');
          await Future.delayed(Duration.zero);
          expect(values, equals(<String>['hello', 'world']));

          await cached.dispose();
          await source.dispose();
        },
      );

      test('cache() on an already-replaying subject returns itself', () async {
        expect(subject.cache(), same(subject));
      });
    });

    group('Listen', () {
      test('listen should subscribe to stream', () async {
        final values = <int>[];
        final subscription = subject.listen(values.add);

        subject.add(1);
        subject.add(2);

        await Future.delayed(Duration.zero);
        expect(values, equals([0, 1, 2]));

        await subscription.cancel();
      });

      test('listenManaged should auto-cancel on dispose', () async {
        final values = <int>[];
        subject.listenManaged(values.add);

        subject.add(1);
        await Future.delayed(Duration.zero);

        await subject.dispose();
        // After dispose, no more values should be added
        expect(values, equals([0, 1]));
      });
    });

    group('Static Methods', () {
      test('fromFutureWithError should handle success', () async {
        final future = Future.value(42);
        final fromFuture = ReactiveSubject.fromFutureWithError(future);
        final values = <int>[];

        fromFuture.stream.listen(values.add);

        await Future.delayed(const Duration(milliseconds: 100));
        expect(values, contains(42));
      });

      test('fromFutureWithError should handle errors', () async {
        final future = Future<int>.error('test error');
        final errors = <Object>[];
        final fromFuture = ReactiveSubject.fromFutureWithError(
          future,
          onError: errors.add,
        );

        fromFuture.stream.listen(null, onError: (_) {});

        await Future.delayed(const Duration(milliseconds: 100));
        expect(errors, contains('test error'));
      });

      test('fromFutureWithError should handle timeout', () async {
        final future = Future.delayed(const Duration(seconds: 2), () => 42);
        final errors = <Object>[];
        final fromFuture = ReactiveSubject.fromFutureWithError(
          future,
          timeout: const Duration(milliseconds: 100),
          onError: errors.add,
        );

        fromFuture.stream.listen(null, onError: (_) {});

        await Future.delayed(const Duration(milliseconds: 200));
        expect(errors.isNotEmpty, isTrue);
      });
    });

    group('Broadcast Subject', () {
      test('broadcast should support multiple subscribers', () async {
        final broadcast = ReactiveSubject<int>.broadcast(initialValue: 0);
        final values1 = <int>[];
        final values2 = <int>[];

        // Broadcast subjects don't replay initial value to late subscribers
        broadcast.stream.listen(values1.add);
        broadcast.stream.listen(values2.add);

        broadcast.add(1);
        broadcast.add(2);

        await Future.delayed(Duration.zero);
        // PublishSubject doesn't emit initial value to subscribers
        expect(values1, containsAll([1, 2]));
        expect(values2, containsAll([1, 2]));

        await broadcast.dispose();
      });
    });
  });
}
