part of 'count_bloc.dart';

abstract class CountEvent extends MainBlocEvent {
  const CountEvent._();
}

@freezed
sealed class Increment extends CountEvent with _$Increment {
  const Increment._() : super._();
  const factory Increment() = _Increment;
}

@freezed
sealed class Decrement extends CountEvent with _$Decrement {
  const Decrement._() : super._();
  const factory Decrement() = _Decrement;
}
