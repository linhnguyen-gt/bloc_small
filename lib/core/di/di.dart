import 'package:bloc_small/common/common_bloc.dart';
import 'package:get_it/get_it.dart';

export 'package:get_it/get_it.dart' show GetIt;

final GetIt getIt = GetIt.instance;

void configureInjection() {
  getIt.registerFactory<CommonBloc>(() => CommonBloc());
}
