part of 'search_bloc.dart';

@freezed
sealed class SearchState extends MainBlocState with _$SearchState {
  const SearchState._();
  const factory SearchState.initial() = Initial;
  const factory SearchState.loaded(List<String> results) = Loaded;
  const factory SearchState.error(String message) = Error;
}
