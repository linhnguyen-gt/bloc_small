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
        loadingStates: {LoadingKey.global: true, 'custom_key': false},
      );
      expect(state.isLoading(), isTrue);
      expect(state.isLoading(key: 'custom_key'), isFalse);
    });

    test('copyWith creates a new instance with updated values', () {
      const initialState = CommonState();
      final updatedState = initialState.copyWith(
        loadingStates: const {LoadingKey.global: true},
      );

      expect(updatedState.loadingStates, equals({LoadingKey.global: true}));
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
              equals({LoadingKey.global: true}),
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'updates existing loading state when SetComponentLoading is added',
      build: () => CommonBloc(),
      seed:
          () => const CommonState(
            loadingStates: {LoadingKey.global: true, 'custom_key': false},
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
              equals({LoadingKey.global: false, 'custom_key': false}),
            ),
          ],
    );

    blocTest<CommonBloc, CommonState>(
      'adds new loading state when SetComponentLoading is added with new key',
      build: () => CommonBloc(),
      seed: () => const CommonState(loadingStates: {LoadingKey.global: true}),
      act:
          (bloc) => bloc.add(
            const SetComponentLoading(key: 'new_key', isLoading: true),
          ),
      expect:
          () => [
            isA<CommonState>().having(
              (state) => state.loadingStates,
              'loadingStates',
              equals({LoadingKey.global: true, 'new_key': true}),
            ),
          ],
    );
  });
}
