part of 'search_bloc.dart';

abstract class SearchEvent extends MainBlocEvent {
  const SearchEvent._();
}

@freezed
sealed class UpdateQuery extends SearchEvent with _$UpdateQuery {
  const UpdateQuery._() : super._();
  const factory UpdateQuery(String query) = _UpdateQuery;
}

@freezed
sealed class UpdateResults extends SearchEvent with _$UpdateResults {
  const UpdateResults._() : super._();
  const factory UpdateResults(List<String> results) = _UpdateResults;
}

@freezed
sealed class SearchError extends SearchEvent with _$SearchError {
  const SearchError._() : super._();
  const factory SearchError(String message) = _SearchError;
}
