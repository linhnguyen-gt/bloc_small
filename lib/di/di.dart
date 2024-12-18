import 'package:bloc_small/common/common_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

export 'package:get_it/get_it.dart' show GetIt;

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureInjection() {
  getIt.registerFactory<CommonBloc>(() => CommonBloc());
}
