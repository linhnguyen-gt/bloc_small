part of 'reactive_subject.dart';

// Combination methods for ReactiveSubject
extension ReactiveSubjectCombinationsExtension<T> on ReactiveSubject<T> {

  /// Combines the latest values of two ReactiveSubjects using a specified combiner function.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<String>(initialValue: 'a');
  /// final combined = subject1.withLatestFrom(subject2, (int a, String b) => '$a$b');
  /// combined.stream.listen(print); // Prints: 1a
  /// subject1.add(2); // Prints: 2a
  /// ```
  ReactiveSubject<R> withLatestFrom<S, R>(
    ReactiveSubject<S> other,
    R Function(T event, S latestFromOther) combiner,
  ) {
    return _deriveReactiveSubject<R>(
      stream.withLatestFrom(other.stream, combiner),
    );
  }

  /// Prepends a given value to the source ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final started = subject.startWith(0);
  /// started.stream.listen(print); // Prints: 0, 1
  /// subject.add(2); // Prints: 2
  /// ```
  ReactiveSubject<T> startWith(T startValue) {
    // Seed via the subject's initialValue only. Also applying
    // `stream.startWith(startValue)` seeded a second time, emitting the start
    // value twice (I10).
    return _deriveReactiveSubject<T>(
      stream,
      into: ReactiveSubject<T>(initialValue: startValue),
    );
  }

  /// Applies an accumulator function over the source ReactiveSubject, and returns each intermediate result as a ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final sum = subject.scan<int>(0, (accumulated, current, index) => accumulated + current);
  /// sum.stream.listen(print); // Prints: 1
  /// subject.add(2); // Prints: 3
  /// subject.add(3); // Prints: 6
  /// ```
  ReactiveSubject<R> scan<R>(
    R initialValue,
    R Function(R accumulated, T current, int index) accumulator,
  ) {
    return _deriveReactiveSubject<R>(stream.scan(accumulator, initialValue));
  }
}
