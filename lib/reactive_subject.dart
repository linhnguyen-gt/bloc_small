import 'package:rxdart/rxdart.dart';

/// A wrapper class for RxDart subjects that provides a simplified interface for reactive programming.
///
/// This class encapsulates either a BehaviorSubject or a PublishSubject and provides methods
/// to interact with the underlying subject in a more convenient way.
///
/// Usage:
/// ```dart
/// // Create a ReactiveSubject with an initial value
/// final subject = ReactiveSubject<int>(initialValue: 0);
///
/// // Add a value
/// subject.add(1);
///
/// // Listen to the stream
/// subject.stream.listen((value) => print(value));
///
/// // Get the current value
/// print(subject.value);
///
/// // Dispose when done
/// subject.dispose();
/// ```
///
/// Usage with StreamBuilder in a widget:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   _MyWidgetState createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final ReactiveSubject<int> _counter = ReactiveSubject<int>(initialValue: 0);
///
///   @override
///   void dispose() {
///     _counter.dispose();
///     super.dispose();
///   }
///
///   void _incrementCounter() {
///     _counter.add(_counter.value + 1);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Center(
///         child: StreamBuilder<int>(
///           stream: _counter.stream,
///           builder: (context, snapshot) {
///             if (snapshot.hasData) {
///               return Text('Counter: ${snapshot.data}');
///             } else {
///               return CircularProgressIndicator();
///             }
///           },
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: _incrementCounter,
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
class ReactiveSubject<T> {
  /// Creates a ReactiveSubject with a BehaviorSubject.
  ///
  /// [initialValue] is the initial value of the subject, if provided.
  ReactiveSubject({T? initialValue}) : _subject = BehaviorSubject<T>() {
    if (initialValue != null) add(initialValue);
  }

  /// Creates a ReactiveSubject with a PublishSubject.
  ///
  /// [initialValue] is the initial value of the subject, if provided.
  ReactiveSubject.broadcast({T? initialValue})
      : _subject = PublishSubject<T>() {
    if (initialValue != null) add(initialValue);
  }

  late T _value;

  /// The current value of the subject.
  T get value => _value;

  final Subject<T> _subject;

  /// The stream of the underlying subject.
  Stream<T> get stream => _subject.stream;

  /// The sink of the underlying subject.
  Sink<T> get sink => _subject.sink;

  /// Whether the underlying subject is closed.
  bool get isClosed => _subject.isClosed;

  /// Adds a new value to the subject.
  ///
  /// Updates the current value and adds it to the stream if the subject is not closed.
  void add(T value) {
    _value = value;
    if (!_subject.isClosed) _subject.add(value);
  }

  /// Adds an error to the subject.
  void addError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
  }

  /// Closes the underlying subject.
  void dispose() {
    _subject.close();
  }

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
    stream.map(mapper).listen(result.add);
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
    stream.where(test).listen(result.add);
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
  ReactiveSubject<R> switchMap<R>(Stream<R> Function(T event) mapper) {
    final result = ReactiveSubject<R>();
    stream.switchMap(mapper).listen(result.add);
    return result;
  }

  /// Emits items from the source ReactiveSubject only after a specified duration has passed without the ReactiveSubject emitting any other items.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<String>();
  /// final debounced = subject.debounceTime(Duration(seconds: 1));
  /// debounced.stream.listen(print);
  /// subject.add('a');
  /// subject.add('b');
  /// subject.add('c'); // After 1 second, prints: c
  /// ```
  ReactiveSubject<T> debounceTime(Duration duration) {
    final result = ReactiveSubject<T>();
    stream.debounceTime(duration).listen(result.add);
    return result;
  }

  /// Emits the first item emitted by the source ReactiveSubject in each time window of a specified duration.
  ///
  /// Usage:
  /// ```dart
  /// final subject = ReactiveSubject<int>();
  /// final throttled = subject.throttleTime(Duration(seconds: 1));
  /// throttled.stream.listen(print);
  /// subject.add(1); // Prints: 1
  /// subject.add(2);
  /// subject.add(3); // After 1 second, prints: 3
  /// ```
  ReactiveSubject<T> throttleTime(Duration duration) {
    final result = ReactiveSubject<T>();
    stream.throttleTime(duration).listen(result.add);
    return result;
  }

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
    stream.distinct(equals).listen(result.add);
    return result;
  }

  /// Combines the latest values of multiple ReactiveSubjects into a single ReactiveSubject that emits a List of those values.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<String>(initialValue: 'a');
  /// final combined = ReactiveSubject.combineLatest([subject1, subject2]);
  /// combined.stream.listen(print); // Prints: [1, 'a']
  /// subject1.add(2); // Prints: [2, 'a']
  /// ```
  static ReactiveSubject<List<T>> combineLatest<T>(
      List<ReactiveSubject<T>> subjects) {
    final result = ReactiveSubject<List<T>>();
    Rx.combineLatestList(subjects.map((s) => s.stream)).listen(result.add);
    return result;
  }

  /// Merges multiple ReactiveSubjects into a single ReactiveSubject.
  ///
  /// Usage:
  /// ```dart
  /// final subject1 = ReactiveSubject<int>(initialValue: 1);
  /// final subject2 = ReactiveSubject<int>(initialValue: 2);
  /// final merged = ReactiveSubject.merge([subject1, subject2]);
  /// merged.stream.listen(print); // Prints: 1, 2
  /// subject1.add(3); // Prints: 3
  /// ```
  static ReactiveSubject<T> merge<T>(List<ReactiveSubject<T>> subjects) {
    final result = ReactiveSubject<T>();
    Rx.merge(subjects.map((s) => s.stream)).listen(result.add);
    return result;
  }

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
  ReactiveSubject<R> withLatestFrom<S, R>(ReactiveSubject<S> other,
      R Function(T event, S latestFromOther) combiner) {
    final result = ReactiveSubject<R>();
    stream.withLatestFrom(other.stream, combiner).listen(result.add);
    return result;
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
    final result = ReactiveSubject<T>();
    stream.startWith(startValue).listen(result.add);
    return result;
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
  ReactiveSubject<R> scan<R>(R initialValue,
      R Function(R accumulated, T current, int index) accumulator) {
    final result = ReactiveSubject<R>();
    stream.scan(accumulator, initialValue).listen(result.add);
    return result;
  }
}
