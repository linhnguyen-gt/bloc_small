import 'package:bloc_small/bloc/common/common_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../base/base_app_router.dart';
import '../../../navigation/app_navigator.dart';

export 'package:get_it/get_it.dart' show GetIt;

/// Global instance of GetIt for dependency injection
final getIt = GetIt.instance;

@module
abstract class CoreModule {
  @singleton
  CommonBloc get commonBloc => CommonBloc();
}

extension CoreInjection on GetIt {
  /// Registers core dependencies if they haven't been registered yet
  ///
  /// This method ensures that [CommonBloc] is only registered once.
  ///
  /// Example:
  /// ```dart
  /// void configureInjectionApp() {
  ///   getIt.registerCore();
  /// }
  /// ```
  void registerCore() {
    if (!isRegistered<CommonBloc>()) {
      registerFactory<CommonBloc>(() => CommonBloc());
    }
  }

  /// Registers the app router and navigator for navigation management
  ///
  /// Parameters:
  /// - [router]: The router instance that extends [BaseAppRouter]
  ///
  /// This method:
  /// 1. Registers the router as a singleton
  /// 2. Creates and registers an [AppNavigator] instance
  ///
  /// Example:
  /// ```dart
  /// void configureInjectionApp() {
  ///   final appRouter = AppRouter();
  ///   getIt.registerAppRouter<AppRouter>(appRouter);
  /// }
  /// ```
  ///
  /// Note: The router registration is skipped if it's already registered
  /// or if the provided router is null.
  void registerAppRouter<T extends BaseAppRouter>(T? router) {
    if (router == null) return;

    if (!isRegistered<T>()) {
      registerLazySingleton<BaseAppRouter>(() => get<T>());
      registerLazySingleton<AppNavigator>(() => AppNavigator(get<T>()));
    }
  }
}
