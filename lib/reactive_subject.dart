import 'package:rxdart/rxdart.dart';

class ReactiveSubject<T> {
  ReactiveSubject({T? initialValue}) : _subject = BehaviorSubject<T>() {
    if (initialValue != null) add(initialValue);
  }

  ReactiveSubject.broadcast({T? initialValue})
      : _subject = PublishSubject<T>() {
    if (initialValue != null) add(initialValue);
  }

  late T _value;

  T get value => _value;

  final Subject<T> _subject;

  Stream<T> get stream => _subject.stream;

  Sink<T> get sink => _subject.sink;

  bool get isClosed => _subject.isClosed;

  void add(T value) {
    _value = value;
    if (!_subject.isClosed) _subject.add(value);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _subject.addError(error, stackTrace);
  }

  void dispose() {
    _subject.close();
  }
}
