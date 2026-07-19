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
        const loadingStates = {LoadingKey.global: 1, 'custom_key': 0};
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
        const state = CommonState(loadingStates: {LoadingKey.global: 1});
        expect(state.isLoading(), isTrue);
      });

      test('should return false when global key is false', () {
        const state = CommonState(loadingStates: {LoadingKey.global: 0});
        expect(state.isLoading(), isFalse);
      });

      test('should return correct value for custom key', () {
        const state = CommonState(
          loadingStates: {
            LoadingKey.global: 0,
            'login': 1,
            'logout': 0,
          },
        );
        expect(state.isLoading(key: 'login'), isTrue);
        expect(state.isLoading(key: 'logout'), isFalse);
        expect(state.isLoading(key: 'unknown'), isFalse);
      });

      test('should use global key as default', () {
        const state = CommonState(loadingStates: {LoadingKey.global: 1});
        expect(state.isLoading(), isTrue);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated loading states', () {
        const initialState = CommonState();
        final updatedState = initialState.copyWith(
          loadingStates: const {LoadingKey.global: 1},
        );

        expect(updatedState.loadingStates, equals({LoadingKey.global: 1}));
        expect(initialState.loadingStates, isEmpty);
      });

      test('should keep original values when null is passed', () {
        const initialState = CommonState(
          loadingStates: {LoadingKey.global: 1},
        );
        final updatedState = initialState.copyWith();

        expect(updatedState.loadingStates, equals(initialState.loadingStates));
      });

      test('should replace all loading states', () {
        const initialState = CommonState(
          loadingStates: {LoadingKey.global: 1, 'key1': 1},
        );
        final updatedState = initialState.copyWith(
          loadingStates: const {'key2': 0},
        );

        expect(updatedState.loadingStates, equals({'key2': 0}));
        expect(updatedState.loadingStates.containsKey('key1'), isFalse);
      });
    });

    group('hashCode contract (I19)', () {
      // `==` compares the maps order-independently, but hashCode used
      // Object.hashAll over entries, which is order-*dependent*. Equal states
      // therefore hashed differently and both survived in a Set.
      test('I19: equal states built in different orders hash the same', () {
        final a = CommonState(
          loadingStates: Map<String, int>.fromEntries([
            const MapEntry('a', 1),
            const MapEntry('b', 2),
          ]),
        );
        final b = CommonState(
          loadingStates: Map<String, int>.fromEntries([
            const MapEntry('b', 2),
            const MapEntry('a', 1),
          ]),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect({a, b}, hasLength(1));
      });
    });

    group('Equality', () {
      test('should be equal when loading states are the same', () {
        const state1 = CommonState(
          loadingStates: {LoadingKey.global: 1, 'key1': 0},
        );
        const state2 = CommonState(
          loadingStates: {LoadingKey.global: 1, 'key1': 0},
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when loading states differ', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: 1});
        const state2 = CommonState(loadingStates: {LoadingKey.global: 0});

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when keys differ', () {
        const state1 = CommonState(loadingStates: {'key1': 1});
        const state2 = CommonState(loadingStates: {'key2': 1});

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when map sizes differ', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: 1});
        const state2 = CommonState(
          loadingStates: {LoadingKey.global: 1, 'key1': 0},
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should be equal to itself', () {
        const state = CommonState(loadingStates: {LoadingKey.global: 1});

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
        const state = CommonState(loadingStates: {LoadingKey.global: 1});
        final string = state.toString();

        expect(string, contains('CommonState'));
        expect(string, contains('loadingStates'));
      });

      test('should include loading states in string', () {
        const state = CommonState(
          loadingStates: {LoadingKey.global: 1, 'custom': 0},
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
            'key1': 1,
            'key2': 0,
            'key3': 1,
            'key4': 0,
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
            'key-with-dash': 1,
            'key_with_underscore': 0,
            'key.with.dot': 1,
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
          loadingStates: {LoadingKey.global: 1},
        );
        final copiedState = originalState.copyWith(
          loadingStates: const {LoadingKey.global: 0},
        );

        expect(originalState.loadingStates[LoadingKey.global], equals(1));
        expect(copiedState.loadingStates[LoadingKey.global], equals(0));
      });

      test('should create independent copies', () {
        const state1 = CommonState(loadingStates: {LoadingKey.global: 1});
        final state2 = state1.copyWith(loadingStates: const {'new_key': 1});

        expect(state1.loadingStates.containsKey('new_key'), isFalse);
        expect(state2.loadingStates.containsKey('new_key'), isTrue);
      });
    });
  });
}
