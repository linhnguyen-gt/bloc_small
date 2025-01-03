import '../main_bloc_state.dart';

class ErrorState extends MainBlocState {
  final Object error;
  final StackTrace stackTrace;

  ErrorState(this.error, this.stackTrace);
}
