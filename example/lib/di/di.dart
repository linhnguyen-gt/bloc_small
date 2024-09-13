import 'package:bloc_small/common/common_bloc.dart';
import 'di.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjectionApp() => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  CommonBloc get commonBloc => CommonBloc();
}
