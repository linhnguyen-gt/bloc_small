import 'dart:async' as async;

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
    with BaseErrorHandlerMixin {
  TestBloc() : super(const TestState());

  bool loadingHidden = false;

  @override
  void hideLoading({String? key}) {
    loadingHidden = true;
  }
}

// Test Cubit with error handler
class TestCubit extends MainCubit<TestState> with BaseErrorHandlerMixin {
  TestCubit() : super(const TestState());

  bool loadingHidden = false;

  @override
  void hideLoading({String? key}) {
    loadingHidden = true;
  }
}

void main() {
  group('BaseErrorHandlerMixin', () {
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
          const error = NetworkException('Connection failed');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('Please check your internet connection'));
        },
      );

      flutter_test.test(
        'should return validation message for ValidationException',
        () {
          const error = ValidationException('Invalid input');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('Invalid input'));
        },
      );

      flutter_test.test(
        'should return timeout message for AppTimeoutException',
        () {
          const error = AppTimeoutException('Request timeout');
          final message = bloc.getErrorMessage(error);
          expect(message, equals('The operation timed out'));
        },
      );

      // I4: before the rename, the local TimeoutException shadowed
      // dart:async's, so a real Future.timeout error fell through to the
      // generic branch.
      flutter_test.test(
        'I4: should return timeout message for dart:async TimeoutException',
        () {
          final error = async.TimeoutException('Request timeout');
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
      // handleError must NOT hide loading. catchError's `finally` owns that
      // and is the only place guaranteed to pair with the matching
      // showLoading; hiding in both decrements a refcounted key twice for a
      // single increment, clearing the spinner while a concurrent operation
      // on the same key is still running.
      flutter_test.test('should not hide loading when error occurs', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        await bloc.handleError(error, stackTrace);

        expect(bloc.loadingHidden, isFalse);
      });

      flutter_test.test('should log error information', () async {
        const error = NetworkException('Connection failed');
        final stackTrace = StackTrace.current;

        // Should not throw
        await bloc.handleError(error, stackTrace);
        expect(bloc.loadingHidden, isFalse);
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
              if (callCount > 0) {
                throw Exception('Persistent failure');
              }
              return 'unreachable';
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

  group('BaseErrorHandlerMixin', () {
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
          const error = NetworkException('Connection failed');
          final message = cubit.getErrorMessage(error);
          expect(message, equals('Please check your internet connection'));
        },
      );

      flutter_test.test(
        'should return validation message for ValidationException',
        () {
          const error = ValidationException('Invalid input');
          final message = cubit.getErrorMessage(error);
          expect(message, equals('Invalid input'));
        },
      );

      flutter_test.test(
        'should return timeout message for AppTimeoutException',
        () {
          const error = AppTimeoutException('Request timeout');
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
      flutter_test.test('should not hide loading when error occurs', () async {
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        await cubit.handleError(error, stackTrace);

        expect(cubit.loadingHidden, isFalse);
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
              if (callCount > 0) {
                throw Exception('Persistent failure');
              }
              return 'unreachable';
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
