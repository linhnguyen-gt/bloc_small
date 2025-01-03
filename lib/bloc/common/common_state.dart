part of 'common_bloc.dart';

class CommonState extends MainBlocState {
  final Map<String, bool> loadingStates;

  const CommonState({this.loadingStates = const {}});

  bool isLoading(String key) => loadingStates[key] ?? false;

  CommonState copyWith({Map<String, bool>? loadingStates}) {
    return CommonState(
      loadingStates: loadingStates ?? this.loadingStates,
    );
  }
}
