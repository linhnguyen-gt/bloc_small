import 'package:bloc_small/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkException', () {
    test('should create with default message', () {
      const exception = NetworkException();
      expect(exception.message, equals('A network error occurred'));
    });

    test('should create with custom message', () {
      const exception = NetworkException('Connection timeout');
      expect(exception.message, equals('Connection timeout'));
    });

    test('should be an Exception', () {
      const exception = NetworkException();
      expect(exception, isA<Exception>());
    });
  });

  group('ValidationException', () {
    test('should create with default message', () {
      const exception = ValidationException();
      expect(exception.message, equals('A validation error occurred'));
    });

    test('should create with custom message', () {
      const exception = ValidationException('Invalid email format');
      expect(exception.message, equals('Invalid email format'));
    });

    test('should be an Exception', () {
      const exception = ValidationException();
      expect(exception, isA<Exception>());
    });
  });

  group('AppTimeoutException', () {
    test('should create with default message', () {
      const exception = AppTimeoutException();
      expect(exception.message, equals('A timeout error occurred'));
    });

    test('should create with custom message', () {
      const exception = AppTimeoutException('Request timed out after 30s');
      expect(exception.message, equals('Request timed out after 30s'));
    });

    test('should be an Exception', () {
      const exception = AppTimeoutException();
      expect(exception, isA<Exception>());
    });
  });
}
