import 'package:bloc_small/core/error/bloc_error_handler.dart';
import 'package:bloc_small/core/error/exceptions.dart';
import 'package:bloc_small/presentation/bloc/main_bloc.dart';
import 'package:bloc_small/presentation/bloc/main_bloc_event.dart';
import 'package:bloc_small/presentation/bloc/main_bloc_state.dart';
import 'package:bloc_small/presentation/cubit/main_cubit.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:flutter_test/flutter_test.dart' hide test;

// Test Event
abstract class TestEvent extends MainBlocEvent {
  const TestEvent();
}

class DoSomethingEvent extends TestEvent {
  const DoSomethingEvent();
}

// Test State
class TestState extends MainBlocState {
  final int count;
  const TestState({this.count = 0});

  TestState copyWith({int? count}) {
    return TestState(count: count ?? this.count);
  }
}

// Test Bloc with error handler
class TestBloc extends MainBloc<TestEvent, TestState>
    with BlocErrorHandlerMixin {
  TestBloc() : super(const TestState());

  bool loadingHidden = false;

  @override
  void hideLoading({String? key}) {
    loadingHidden = true;
  }
}

// Test Cubit with error handler
class TestCubit extends MainCubit<TestState> with CubitErrorHandlerMixin {
  TestCubit() : super(const TestState());

  bool loadingHidden = false;

  @override
  void hideLoading({String? key}) {
    loadingHidden = true;
  }
}

void main() {
  group('BlocErrorHandlerMixin', () {
    late TestBloc bloc;

    setUp(() {
      bloc = TestBloc();
    });

    tearDown(() {
      bloc.close();
    });

    group('getErrorMessage', () {
      flutter_test.test(
        'should return network error message for NetworkException',
        () {
          final error = NetworkException('Connection failed');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('Please check your internet connection'));
        },
      );

      flutter_test.test(
        'should return validation message for ValidationException',
        () {
          final error = ValidationException('Invalid input');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('Invalid input'));
        },
      );

      flutter_test.test(
        'should return timeout message for TimeoutException',
        () {
          final error = TimeoutException('Request timeout');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('The operation timed out'));
        },
      );

      flutter_test.test('should return generic message for unknown errors', () {
        final error = Exception('Unknown error');
        final message = bloc.getErrorMessage(error);
        expect(message, equals('An unexpected error occurred'));
      });
    });

    group('handleError', () {
      flutter_test.test('should hide loading when error occurs', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        await bloc.handleError(error, stackTrace);

        expect(bloc.loadingHidden, isTrue);
      });

      flutter_test.test('should log error information', () async {
        final error = NetworkException('Connection failed');
        final stackTrace = StackTrace.current;

        // Should not throw
        await bloc.handleError(error, stackTrace);
        expect(bloc.loadingHidden, isTrue);
      });
    });

    group('retryOperation', () {
      flutter_test.test('should succeed on first attempt', () async {
        var callCount = 0;
        await bloc.retryOperation(
          operation: () async {
            callCount++;
            return 'success';
          },
        );

        expect(callCount, equals(1));
      });

      flutter_test.test('should retry on failure and succeed', () async {
        var callCount = 0;
        await bloc.retryOperation(
          operation: () async {
            callCount++;
            if (callCount < 2) {
              throw Exception('Temporary failure');
            }
            return 'success';
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
        );

        expect(callCount, equals(2));
      });

      flutter_test.test('should throw after max attempts', () async {
        var callCount = 0;

        try {
          await bloc.retryOperation(
            operation: () async {
              callCount++;
              throw Exception('Persistent failure');
            },
            maxAttempts: 3,
            delay: const Duration(milliseconds: 10),
          );
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(callCount, equals(3));
        }
      });

      flutter_test.test('should respect delay between retries', () async {
        final startTime = DateTime.now();
        var callCount = 0;

        try {
          await bloc.retryOperation(
            operation: () async {
              callCount++;
              throw Exception('Failure');
            },
            maxAttempts: 3,
            delay: const Duration(milliseconds: 50),
          );
        } catch (_) {
          // Expected to fail
        }

        final duration = DateTime.now().difference(startTime);
        expect(duration.inMilliseconds, greaterThanOrEqualTo(100)); // 2 delays
        expect(callCount, equals(3));
      });
    });
  });

  group('CubitErrorHandlerMixin', () {
    late TestCubit cubit;

    setUp(() {
      cubit = TestCubit();
    });

    tearDown(() {
      cubit.close();
    });

    group('getErrorMessage', () {
      flutter_test.test(
        'should return network error message for NetworkException',
        () {
          final error = NetworkException('Connection failed');
          final message = cubit.getErrorMessage(error);
          expect(message, equals('Please check your internet connection'));
        },
      );

      flutter_test.test(
        'should return validation message for ValidationException',
        () {
          final error = ValidationException('Invalid input');
          final message = cubit.getErrorMessage(error);
          expect(message, equals('Invalid input'));
        },
      );

      flutter_test.test(
        'should return timeout message for TimeoutException',
        () {
          final error = TimeoutException('Request timeout');
          final message = cubit.getErrorMessage(error);
          expect(message, equals('The operation timed out'));
        },
      );

      flutter_test.test('should return generic message for unknown errors', () {
        final error = Exception('Unknown error');
        final message = cubit.getErrorMessage(error);
        expect(message, equals('An unexpected error occurred'));
      });
    });

    group('handleError', () {
      flutter_test.test('should hide loading when error occurs', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        await cubit.handleError(error, stackTrace);

        expect(cubit.loadingHidden, isTrue);
      });
    });

    group('retryOperation', () {
      flutter_test.test('should succeed on first attempt', () async {
        var callCount = 0;
        await cubit.retryOperation(
          operation: () async {
            callCount++;
            return 'success';
          },
        );

        expect(callCount, equals(1));
      });

      flutter_test.test('should retry on failure and succeed', () async {
        var callCount = 0;
        await cubit.retryOperation(
          operation: () async {
            callCount++;
            if (callCount < 2) {
              throw Exception('Temporary failure');
            }
            return 'success';
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 10),
        );

        expect(callCount, equals(2));
      });

      flutter_test.test('should throw after max attempts', () async {
        var callCount = 0;

        try {
          await cubit.retryOperation(
            operation: () async {
              callCount++;
              throw Exception('Persistent failure');
            },
            maxAttempts: 3,
            delay: const Duration(milliseconds: 10),
          );
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(callCount, equals(3));
        }
      });
    });
  });
}
