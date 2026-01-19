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
    final result = ReactiveSubject<T>();
    stream.distinct(equals).listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits items that are distinct based on a key selector function.
  /// This is more efficient than distinct() when you only need to compare specific properties.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<User>();
  /// final distinctById = subject.distinctBy((user) => user.id);
  /// distinctById.stream.listen(print);
  /// ```
  ReactiveSubject<T> distinctBy<K>(K Function(T value) keySelector) {
    final result = ReactiveSubject<T>();
    final seenKeys = <K>{};

    stream
        .where((value) {
          final key = keySelector(value);
          if (seenKeys.contains(key)) {
            return false;
          }
          seenKeys.add(key);
          return true;
        })
        .listen(result.add, onError: result.addError);

    return result;
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
    final shared = stream.share();
    final result = ReactiveSubject<T>();
    shared.listen(result.add, onError: result.addError);
    return result;
  }

  /// Shares a single subscription and replays the specified number of latest values to new subscribers.
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
    final shared = stream.shareReplay(maxSize: maxSize);
    final result = ReactiveSubject<T>();
    shared.listen(result.add, onError: result.addError);
    return result;
  }

  /// Groups stream events into separate lists based on a key selector function.
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
    final result = ReactiveSubject<Map<K, List<T>>>();
    final groups = <K, List<T>>{};

    stream.listen((value) {
      final key = keySelector(value);
      groups.putIfAbsent(key, () => []).add(value);
      result.add(Map.from(groups));
    }, onError: result.addError);

    return result;
  }
}
