import 'package:bloc_small/bloc/common/common_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../base/base_app_router.dart';
import '../../../navigation/app_navigator.dart';

export 'package:get_it/get_it.dart' show GetIt;

final getIt = GetIt.instance;

@module
abstract class CoreModule {
  @singleton
  CommonBloc get commonBloc => CommonBloc();
}

extension CoreInjection on GetIt {
  void registerCore() {
    if (!isRegistered<CommonBloc>()) {
      registerFactory<CommonBloc>(() => CommonBloc());
    }
  }

  void registerAppRouter<T extends BaseAppRouter>(T? router) {
    if (router == null) return;

    if (!isRegistered<T>()) {
      registerLazySingleton<BaseAppRouter>(() => get<T>());
      registerLazySingleton<AppNavigator>(() => AppNavigator(get<T>()));
    }
  }
}
