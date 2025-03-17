part of 'count_bloc.dart';

@freezed
sealed class CountState extends MainBlocState with _$CountState {
  const CountState._();
  const factory CountState.initial({@Default(0) int count}) = _Initial;
}
