import 'package:bloc_small/core/constants/default_loading.dart';
import 'package:bloc_small/presentation/bloc/common_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonState', () {
    group('Constructor', () {
      test('should create with empty loading states by default', () {
        const state = CommonState();
        expect(state.loadingStates, isEmpty);
      });

      test('should create with provided loading states', () {
        const loadingStates = {LoadingKey.global: true, 'custom_key': false};
        const state = CommonState(loadingStates: loadingStates);
        expect(state.loadingStates, equals(loadingStates));
      });
    });

    group('isLoading', () {
      test('should return false when key not present', () {
        const state = CommonState();
        expect(state.isLoading(), isFalse);
        expect(state.isLoading(key: 'custom_key'), isFalse);
      });

      test('should return true when global key is true', () {
        const state = CommonState(loadingStates: {LoadingKey.global: true});
        expect(state.isLoading(), isTrue);
      });

      test('should return false when global key is false', () {
        const state = CommonState(loadingStates: {LoadingKey.global: false});
        expect(state.isLoading(), isFalse);
      });

      test('should return correct value for custom key', () {
        const state = CommonState(
          loadingStates: {
            LoadingKey.global: false,
            'login': true,
            'logout': false,
          },
        );
        expect(state.isLoading(key: 'login'), isTrue);
        expect(state.isLoading(key: 'logout'), isFalse);
        expect(state.isLoading(key: 'unknown'), isFalse);
      });

      test('should use global key as default', () {
        const state = CommonState(loadingStates: {LoadingKey.global: true});
        expect(state.isLoading(), isTrue);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated loading states', () {
        const initialState = CommonState();
        final updatedState = initialState.copyWith(
          loadingStates: const {LoadingKey.global: true},
        );

        expect(updatedState.loadingStates, equals({LoadingKey.global: true}));
        expect(initialState.loadingStates, isEmpty);
      });

      test('should keep original values when null is passed', () {
        const initialState = CommonState(
          loadingStates: {LoadingKey.global: true},
        );
        final updatedState = initialState.copyWith();

        expect(updatedState.loadingStates, equals(initialState.loadingStates));
      });

      test('should replace all loading states', () {
        const initialState = CommonState(
          loadingStates: {LoadingKey.global: true, 'key1': true},
        );
        final updatedState = initialState.copyWith(
          loadingStates: const {'key2': false},
        );

        expect(updatedState.loadingStates, equals({'key2': false}));
        expect(updatedState.loadingStates.containsKey('key1'), isFalse);
      });
    });

    group('Equality', () {
      test('should be equal when loading states are the same', () {
        const state1 = CommonState(
          loadingStates: {LoadingKey.global: true, 'key1': false},
        );
        const state2 = CommonState(
          loadingStates: {LoadingKey.global: true, 'key1': false},
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when loading states differ', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: true});
        const state2 = CommonState(loadingStates: {LoadingKey.global: false});

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when keys differ', () {
        const state1 = CommonState(loadingStates: {'key1': true});
        const state2 = CommonState(loadingStates: {'key2': true});

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when map sizes differ', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: true});
        const state2 = CommonState(
          loadingStates: {LoadingKey.global: true, 'key1': false},
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should be equal to itself', () {
        const state = CommonState(loadingStates: {LoadingKey.global: true});

        expect(state, equals(state));
        expect(identical(state, state), isTrue);
      });

      test('should not be equal to different type', () {
        const state = CommonState();
        expect(state, isNot(equals('not a state')));
        expect(state, isNot(equals(42)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        const state = CommonState(loadingStates: {LoadingKey.global: true});
        final string = state.toString();

        expect(string, contains('CommonState'));
        expect(string, contains('loadingStates'));
      });

      test('should include loading states in string', () {
        const state = CommonState(
          loadingStates: {LoadingKey.global: true, 'custom': false},
        );
        final string = state.toString();

        expect(string, contains(LoadingKey.global));
        expect(string, contains('custom'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty map correctly', () {
        const state = CommonState(loadingStates: {});
        expect(state.loadingStates, isEmpty);
        expect(state.isLoading(), isFalse);
      });

      test('should handle multiple keys', () {
        const state = CommonState(
          loadingStates: {
            'key1': true,
            'key2': false,
            'key3': true,
            'key4': false,
          },
        );

        expect(state.isLoading(key: 'key1'), isTrue);
        expect(state.isLoading(key: 'key2'), isFalse);
        expect(state.isLoading(key: 'key3'), isTrue);
        expect(state.isLoading(key: 'key4'), isFalse);
      });

      test('should handle special characters in keys', () {
        const state = CommonState(
          loadingStates: {
            'key-with-dash': true,
            'key_with_underscore': false,
            'key.with.dot': true,
          },
        );

        expect(state.isLoading(key: 'key-with-dash'), isTrue);
        expect(state.isLoading(key: 'key_with_underscore'), isFalse);
        expect(state.isLoading(key: 'key.with.dot'), isTrue);
      });
    });

    group('Immutability', () {
      test('should not modify original state when copying', () {
        const originalState = CommonState(
          loadingStates: {LoadingKey.global: true},
        );
        final copiedState = originalState.copyWith(
          loadingStates: const {LoadingKey.global: false},
        );

        expect(originalState.loadingStates[LoadingKey.global], isTrue);
        expect(copiedState.loadingStates[LoadingKey.global], isFalse);
      });

      test('should create independent copies', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: true});
        final state2 = state1.copyWith(loadingStates: const {'new_key': true});

        expect(state1.loadingStates.containsKey('new_key'), isFalse);
        expect(state2.loadingStates.containsKey('new_key'), isTrue);
      });
    });
  });
}
