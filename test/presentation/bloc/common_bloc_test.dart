import 'package:bloc_small/core/constants/default_loading.dart';
import 'package:bloc_small/presentation/bloc/common_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonState', () {
    test('initial state has empty loading states', () {
      const state = CommonState();
      expect(state.loadingStates, isEmpty);
    });

    test('isLoading returns false when key not present', () {
      const state = CommonState();
      expect(state.isLoading(), isFalse);
      expect(state.isLoading(key: 'custom_key'), isFalse);
    });

    test('isLoading returns correct value when key is present', () {
      const state = CommonState(
        loadingStates: {LoadingKey.global: 1, 'custom_key': 0},
      );
      expect(state.isLoading(), isTrue);
      expect(state.isLoading(key: 'custom_key'), isFalse);
    });

    test('copyWith creates a new instance with updated values', () {
      const initialState = CommonState();
      final updatedState = initialState.copyWith(
        loadingStates: const {LoadingKey.global: 1},
      );

      expect(updatedState.loadingStates, equals({LoadingKey.global: 1}));
      expect(initialState.loadingStates, isEmpty); // Original state unchanged
    });
  });

  group('CommonBloc', () {
    blocTest<CommonBloc, CommonState>(
      'emits updated state when SetComponentLoading is added',
      build: () => CommonBloc(),
      act:
          (bloc) => bloc.add(
            const SetComponentLoading(key: LoadingKey.global, isLoading: true),
          ),
      expect:
          () => [
            isA<CommonState>().having(
              (state) => state.loadingStates,
              'loadingStates',
              equals({LoadingKey.global: 1}),
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'removes the key when the last holder finishes',
      build: () => CommonBloc(),
      seed:
          () => const CommonState(
            loadingStates: {LoadingKey.global: 1, 'custom_key': 2},
          ),
      act:
          (bloc) => bloc.add(
            const SetComponentLoading(key: LoadingKey.global, isLoading: false),
          ),
      expect:
          () => [
            isA<CommonState>().having(
              (state) => state.loadingStates,
              'loadingStates',
              // global drops to zero and is removed; custom_key still has two
              // holders and is untouched.
              equals({'custom_key': 2}),
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'adds new loading state when SetComponentLoading is added with new key',
      build: () => CommonBloc(),
      seed: () => const CommonState(loadingStates: {LoadingKey.global: 1}),
      act:
          (bloc) => bloc.add(
            const SetComponentLoading(key: 'new_key', isLoading: true),
          ),
      expect:
          () => [
            isA<CommonState>().having(
              (state) => state.loadingStates,
              'loadingStates',
              equals({LoadingKey.global: 1, 'new_key': 1}),
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'I7: keeps the key while a second holder is still running',
      build: () => CommonBloc(),
      act: (bloc) => bloc
        ..add(const SetComponentLoading(key: 'fetch', isLoading: true))
        ..add(const SetComponentLoading(key: 'fetch', isLoading: true))
        ..add(const SetComponentLoading(key: 'fetch', isLoading: false)),
      expect:
          () => [
            isA<CommonState>().having(
              (s) => s.loadingStates,
              'loadingStates',
              equals({'fetch': 1}),
            ),
            isA<CommonState>().having(
              (s) => s.loadingStates,
              'loadingStates',
              equals({'fetch': 2}),
            ),
            isA<CommonState>().having(
              (s) => s.isLoading(key: 'fetch'),
              'still loading',
              isTrue,
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'I7: an unmatched hide floors at zero rather than going negative',
      build: () => CommonBloc(),
      act: (bloc) => bloc
        ..add(const SetComponentLoading(key: 'fetch', isLoading: false))
        ..add(const SetComponentLoading(key: 'fetch', isLoading: true)),
      expect:
          () => [
            isA<CommonState>().having(
              (s) => s.isLoading(key: 'fetch'),
              'loading after stray hide',
              isFalse,
            ),
            isA<CommonState>().having(
              (s) => s.isLoading(key: 'fetch'),
              'loading after show',
              isTrue,
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'ClearComponentLoading zeroes a key held by several operations',
      build: () => CommonBloc(),
      seed: () => const CommonState(loadingStates: {'fetch': 3}),
      act: (bloc) => bloc.add(const ClearComponentLoading(key: 'fetch')),
      expect:
          () => [
            isA<CommonState>().having(
              (s) => s.loadingStates,
              'loadingStates',
              isEmpty,
            ),
          ],
    );
  });
}
