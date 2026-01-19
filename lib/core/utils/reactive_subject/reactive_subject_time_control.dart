part of 'reactive_subject.dart';

// Time control methods for ReactiveSubject
extension ReactiveSubjectTimeControlExtension<T> on ReactiveSubject<T> {
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
    stream.debounceTime(duration).listen(result.add, onError: result.addError);
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
    stream.throttleTime(duration).listen(result.add, onError: result.addError);
    return result;
  }

  /// Buffers values from the source ReactiveSubject until the closing stream emits.
  ///
  /// When the closing stream emits a value, the buffer is emitted as a List and a new buffer
  /// is started. This is useful for collecting values over time and emitting them as a batch.
  ///
  /// Parameters:
  /// - [closing]: A Stream that determines when to close and emit the current buffer
  ///
  /// Returns a ReactiveSubject that emits Lists of buffered values
  ///
  /// Example:
  /// ```dart
  /// // Create a subject that emits integers
  /// final source = ReactiveSubject<int>();
  ///
  /// // Create a timer that emits every 2 seconds
  /// final closing = Stream.periodic(Duration(seconds: 2));
  ///
  /// // Buffer values until the closing stream emits
  /// final buffered = source.buffer(closing);
  ///
  /// // Listen to the buffered values
  /// buffered.stream.listen((list) => print('Buffered values: $list'));
  ///
  /// // Add values
  /// source.add(1);
  /// source.add(2);
  /// source.add(3);
  /// // After 2 seconds, prints: Buffered values: [1, 2, 3]
  /// ```
  ///
  /// Advanced usage with window size:
  /// ```dart
  /// final source = ReactiveSubject<int>();
  /// final windowSize = 3;
  ///
  /// // Create a closing stream that emits after every N values
  /// final closing = source.stream.bufferCount(windowSize).map((_) => null);
  ///
  /// final buffered = source.buffer(closing);
  /// buffered.stream.listen(print);
  ///
  /// source.add(1);
  /// source.add(2);
  /// source.add(3); // Prints: [1, 2, 3]
  /// source.add(4);
  /// source.add(5);
  /// source.add(6); // Prints: [4, 5, 6]
  /// ```
  ///
  /// Note: Remember to dispose of the source and buffered subjects when they are no longer needed:
  /// ```dart
  /// source.dispose();
  /// buffered.dispose();
  /// ```
  ReactiveSubject<List<T>> buffer(Stream<dynamic> closing) {
    final result = ReactiveSubject<List<T>>();
    stream.buffer(closing).listen(result.add, onError: result.addError);
    return result;
  }
}
