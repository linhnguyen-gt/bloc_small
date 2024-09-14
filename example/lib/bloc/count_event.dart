part of 'count_bloc.dart';

abstract class CountEvent extends MainBlocEvent {
  const CountEvent._();
}

@freezed
class Increment extends CountEvent with _$Increment {
  const factory Increment() = _Increment;
}

@freezed
class Decrement extends CountEvent with _$Decrement {
  const factory Decrement() = _Decrement;
}
