part of 'search_bloc.dart';

@freezed
class SearchState extends MainBlocState with _$SearchState {
  const factory SearchState.initial() = Initial;
  const factory SearchState.loaded(List<String> results) = Loaded;
  const factory SearchState.error(String message) = Error;
}
