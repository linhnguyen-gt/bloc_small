part of 'count_bloc.dart';

@freezed
class CountState extends BaseBlocState with _$CountState {
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
