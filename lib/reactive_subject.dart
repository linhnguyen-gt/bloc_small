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
}
