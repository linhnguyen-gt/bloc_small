import 'package:bloc_small/core/utils/reactive_subject/reactive_subject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReactiveSubject', () {
    test('should emit initial value', () {
      // Arrange
      const initialValue = 42;
      final subject = ReactiveSubject<int>(initialValue: initialValue);

      // Assert
      expect(subject.value, equals(initialValue));
    });

    test('should emit added values', () async {
      // Arrange
      final subject = ReactiveSubject<int>(initialValue: 0);
      final values = <int>[];

      // Act
      subject.stream.listen(values.add);
      subject.add(1);
      subject.add(2);
      subject.add(3);

      // Wait for all events to be processed
      await Future.delayed(Duration.zero);

      // Assert
      expect(values, equals([0, 1, 2, 3]));
    });

    test('should update value property when adding new values', () {
      // Arrange
      final subject = ReactiveSubject<int>(initialValue: 0);

      // Act
      subject.add(42);

      // Assert
      expect(subject.value, equals(42));
    });

    test('should throw error when accessing value without initial value', () {
      // Arrange
      final subject = ReactiveSubject<int>();

      // Assert
      expect(() => subject.value, throwsA(anything));
    });

    test('should map values correctly', () async {
      // Arrange
      final subject = ReactiveSubject<int>(initialValue: 1);
      final mapped = subject.map((i) => i * 2);
      final values = <int>[];

      // Act
      mapped.stream.listen(values.add);
      subject.add(2);
      subject.add(3);

      // Wait for all events to be processed
      await Future.delayed(Duration.zero);

      // Assert
      expect(values, equals([2, 4, 6]));
    });
  });
}
