part of 'common_bloc.dart';

abstract class CommonEvent extends BaseBlocEvent {
  const CommonEvent._();
}

@freezed
class SetComponentLoading extends CommonEvent with _$SetComponentLoading {
  const factory SetComponentLoading(
      {required String key, required bool isLoading}) = _SetComponentLoading;
}
