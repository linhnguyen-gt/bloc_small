part of 'common_bloc.dart';

abstract class CommonEvent extends BaseBlocEvent {
  const CommonEvent();
}

class SetComponentLoading extends CommonEvent {
  final String key;
  final bool isLoading;

  const SetComponentLoading({required this.key, required this.isLoading});
}
