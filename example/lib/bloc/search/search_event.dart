part of 'search_bloc.dart';

abstract class SearchEvent extends MainBlocEvent {
  const SearchEvent._();
}

@freezed
class UpdateQuery extends SearchEvent with _$UpdateQuery {
  const factory UpdateQuery(String query) = _UpdateQuery;
}

@freezed
class UpdateResults extends SearchEvent with _$UpdateResults {
  const factory UpdateResults(List<String> results) = _UpdateResults;
}

@freezed
class SearchError extends SearchEvent with _$SearchError {
  const factory SearchError(String message) = _SearchError;
}
