import 'dart:async';

class Bloc<T> {
  Bloc({T? initialValue}) : _controller = StreamController<T>() {
    if (initialValue != null) add(initialValue);
  }

  Bloc.broadcast({T? initialValue})
      : _controller = StreamController<T>.broadcast() {
    if (initialValue != null) add(initialValue);
  }

  late T _value;

  T get value => _value;

  final StreamController<T> _controller;

  Stream<T> get stream => _controller.stream;

  StreamSink<T> get sink => _controller.sink;

  bool get isClosed => _controller.isClosed;

  void add(T value) {
    _value = value;
    if (!_controller.isClosed) _controller.sink.add(value);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.sink.addError(error, stackTrace);
  }

  void dispose() {
    _controller.close();
  }
}
