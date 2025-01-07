part of 'count_cubit.dart';

@freezed
class CountState extends MainBlocState with _$CountState {
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
