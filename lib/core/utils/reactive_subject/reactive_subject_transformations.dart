part of 'reactive_subject.dart';

// Transformation methods for ReactiveSubject
extension ReactiveSubjectTransformationsExtension<T> on ReactiveSubject<T> {
  /// Transforms the items emitted by the source ReactiveSubject by applying a function to each item.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final doubled = subject.map((i) => i * 2);
  /// doubled.stream.listen(print); // Prints: 2
  /// subject.add(2); // Prints: 4
  /// ```
  ReactiveSubject<R> map<R>(R Function(T event) mapper) {
    final result = ReactiveSubject<R>();
    stream.map(mapper).listen(result.add, onError: result.addError);
    return result;
  }

  /// Filters the items emitted by the source ReactiveSubject by only emitting those that satisfy a specified predicate.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final evens = subject.where((i) => i % 2 == 0);
  /// evens.stream.listen(print);
  /// subject.add(2); // Prints: 2
  /// subject.add(3); // Does not print
  /// ```
  ReactiveSubject<T> where(bool Function(T event) test) {
    final result = ReactiveSubject<T>();
    stream.where(test).listen(result.add, onError: result.addError);
    return result;
  }

  /// Transforms the items emitted by the source ReactiveSubject by applying a function that returns a ReactiveSubject, then emitting the items emitted by the most recently created ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>(initialValue: 1);
  /// final switched = subject.switchMap((i) => ReactiveSubject<String>(initialValue: 'Value: $i'));
  /// switched.stream.listen(print);
  /// subject.add(2); // Prints: Value: 2
  /// ```
  ReactiveSubject<R> switchMap<R>(ReactiveSubject<R> Function(T event) mapper) {
    final newSubject = ReactiveSubject<R>();
    stream
        .switchMap((event) => mapper(event).stream)
        .listen(newSubject.add, onError: newSubject.addError);
    return newSubject;
  }

  /// Transforms each item emitted by the source ReactiveSubject by applying a function that returns a nullable value,
  /// and only emits non-null results.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  /// final mapped = subject.mapNotNull((s) => int.tryParse(s));
  /// mapped.stream.listen(print);
  ///
  /// subject.add('123'); // Prints: 123
  /// subject.add('abc'); // Does not print (null filtered out)
  /// ```
  ReactiveSubject<R> mapNotNull<R>(R? Function(T event) mapper) {
    final result = ReactiveSubject<R>();
    stream
        .map(mapper)
        .whereType<R>()
        .listen(result.add, onError: result.addError);
    return result;
  }

  /// Emits only items that are not null from the source ReactiveSubject.
  ///
  /// Example:
  /// ```dart
  /// final subject = ReactiveSubject<String?>();
  /// final nonNull = subject.whereNotNull();
  /// nonNull.stream.listen(print);
  ///
  /// subject.add('hello'); // Prints: hello
  /// subject.add(null);    // Does not print
  /// ```
  ReactiveSubject<T> whereNotNull() {
    final result = ReactiveSubject<T>();
    stream
        .where((event) => event != null)
        .cast<T>()
        .listen(result.add, onError: result.addError);
    return result;
  }
}
