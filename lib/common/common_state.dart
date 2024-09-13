part of 'common_bloc.dart';

@freezed
class CommonState extends BaseBlocState with _$CommonState {
  const factory CommonState({
    @Default({}) Map<String, bool> loadingStates,
  }) = _CommonState;

  const CommonState._();

  bool isLoading(String key) => loadingStates[key] ?? false;
}
