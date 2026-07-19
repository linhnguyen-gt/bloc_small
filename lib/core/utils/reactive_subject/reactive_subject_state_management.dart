part of 'reactive_subject.dart';

// State management methods for ReactiveSubject
extension ReactiveSubjectStateManagementExtension<T> on ReactiveSubject<T> {
  /// Emits all items emitted by the source ReactiveSubject that are distinct from their immediate predecessors.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final distinct = subject.distinct();
  /// distinct.stream.listen(print);
  /// subject.add(1); // Prints: 1
  /// subject.add(1);
  /// subject.add(2); // Prints: 2
  /// ```
  ReactiveSubject<T> distinct([bool Function(T previous, T next)? equals]) {
    return _deriveReactiveSubject<T>(stream.distinct(equals));
  }

  /// Emits items that are distinct based on a key selector function.
  /// This is more efficient than distinct() when you only need to compare specific properties.
  ///
  /// This is "distinct among every value ever seen", not "distinct from the
  /// immediate predecessor" the way [distinct] is — a key can never repeat
  /// once seen, even if other keys were emitted in between (D12: this is
  /// deliberate, kept as-is rather than changed to distinct-until-changed,
  /// since flipping the semantic would silently alter the output of any
  /// running code that depends on today's behavior). Because every key is
  /// remembered for the lifetime of the returned subject, `seenKeys` grows
  /// without bound on a long-lived stream with unbounded key cardinality —
  /// avoid this operator for streams where that is a concern.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<User>();
  /// final distinctById = subject.distinctBy((user) => user.id);
  /// distinctById.stream.listen(print);
  /// ```
  ReactiveSubject<T> distinctBy<K>(K Function(T value) keySelector) {
    final seenKeys = <K>{};

    return _deriveReactiveSubject<T>(
      stream.where((value) {
        final key = keySelector(value);
        if (seenKeys.contains(key)) {
          return false;
        }
        seenKeys.add(key);
        return true;
      }),
    );
  }

  /// Caches the latest value and replays it to new subscribers.
  ///
  /// Backed by the same replaying (`BehaviorSubject`) mechanism as the
  /// default constructor, so a subscriber that arrives after the source has
  /// already emitted still receives the last value immediately. The
  /// previous implementation built its result on a broadcast
  /// (`PublishSubject`-backed) subject, which structurally cannot replay to
  /// late subscribers, and seeded its "cache" from a variable that was only
  /// ever read before the listener that wrote to it had a chance to run
  /// (C8).
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<String>();
  /// final cached = source.cache();
  ///
  /// source.add('hello');
  ///
  /// // New subscriber gets the cached value immediately
  /// cached.stream.listen(print); // Prints: hello
  /// ```
  ReactiveSubject<T> cache() {
    if (_subject is BehaviorSubject<T>) {
      return this; // Already replays to new subscribers.
    }
    return _deriveReactiveSubject<T>(stream);
  }

  /// Shares a single subscription to the source ReactiveSubject among multiple subscribers.
  ///
  /// This is useful when you want multiple subscribers to share the same subscription
  /// to the source, rather than creating a new subscription for each subscriber.
  ///
  /// Returns a ReactiveSubject that shares its subscription among all subscribers
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final shared = source.share();
  ///
  /// // Both subscribers share the same subscription
  /// shared.stream.listen((value) => print('Subscriber 1: $value'));
  /// shared.stream.listen((value) => print('Subscriber 2: $value'));
  ///
  /// source.add(1);
  /// // Prints:
  /// // Subscriber 1: 1
  /// // Subscriber 2: 1
  /// ```
  ReactiveSubject<T> share() {
    return _deriveReactiveSubject<T>(stream.share());
  }

  /// Shares a single subscription and replays the specified number of latest values to new subscribers.
  ///
  /// Backed by a [ReplaySubject] with the given [maxSize], so late
  /// subscribers actually receive up to `maxSize` values, not just the last
  /// one. Previously the result was always built on the default
  /// `BehaviorSubject`-backed constructor, which can only ever replay 1
  /// regardless of `maxSize` (I9).
  ///
  /// Parameters:
  /// - [maxSize]: The maximum number of values to replay to new subscribers
  ///
  /// Returns a ReactiveSubject that shares and replays values to new subscribers
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final shared = source.shareReplay(maxSize: 2);
  ///
  /// source.add(1);
  /// source.add(2);
  /// source.add(3);
  ///
  /// // New subscriber will receive the last 2 values: 2, 3
  /// shared.stream.listen(print);
  ///
  /// source.add(4); // All subscribers receive: 4
  /// ```
  ReactiveSubject<T> shareReplay({int maxSize = 1}) {
    return _deriveReactiveSubject<T>(
      stream,
      into: ReactiveSubject<T>._withSubject(ReplaySubject<T>(
        maxSize: maxSize,
      )),
    );
  }

  /// Groups stream events into separate lists based on a key selector function.
  ///
  /// Each emission is a fresh `Map` holding fresh `List`s, so a snapshot
  /// handed to a listener is never mutated after the fact — the previous
  /// implementation emitted `Map.from(groups)`, a shallow copy that still
  /// shared its `List` values with every future snapshot, so an already-
  /// delivered snapshot's lists grew retroactively as more events arrived
  /// (I11). `groups` itself grows for the lifetime of the returned subject
  /// — one entry per distinct key, each holding every value seen for that
  /// key — so this operator is unsuitable for a long-lived stream with
  /// unbounded key cardinality or unbounded events per key.
  ///
  /// Parameters:
  /// - [keySelector]: A function that returns a key for each value
  ///
  /// Returns a ReactiveSubject that emits a Map where keys are the results of [keySelector]
  /// and values are lists of items sharing the same key
  ///
  /// Example:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final grouped = source.groupBy((value) => value % 2 == 0 ? 'even' : 'odd');
  ///
  /// grouped.stream.listen((groups) {
  ///   print('Even numbers: ${groups['even']}');
  ///   print('Odd numbers: ${groups['odd']}');
  /// });
  ///
  /// source.add(1); // Odd numbers: [1]
  /// source.add(2); // Even numbers: [2]
  /// source.add(3); // Odd numbers: [1, 3]
  /// ```
  ReactiveSubject<Map<K, List<T>>> groupBy<K>(K Function(T value) keySelector) {
    final groups = <K, List<T>>{};

    return _deriveReactiveSubject<Map<K, List<T>>>(
      stream.map((value) {
        final key = keySelector(value);
        // Replace, don't mutate in place: a snapshot already emitted for
        // this key must keep pointing at the list as it was at that time.
        final updated = List<T>.of(groups[key] ?? const [])..add(value);
        groups[key] = updated;
        return Map<K, List<T>>.of(groups);
      }),
    );
  }
}
