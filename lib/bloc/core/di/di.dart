import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../base/base_app_router.dart';
import '../../../navigation/app_navigator.dart';
import '../../common/common_bloc.dart';

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
    try {
      if (!isRegistered<CommonBloc>()) {
        registerFactory<CommonBloc>(() => CommonBloc());
      }
    } catch (e) {
      throw 'Failed to register core dependencies: $e';
    }
  }

  /// Registers the app router and navigator for navigation management
  ///
  /// Parameters:
  /// - [router]: The router instance that extends [BaseAppRouter]
  /// - [enableNavigationLogs]: Controls whether navigation logs are printed to console
  ///   - true: Navigation logs will be printed (default)
  ///   - false: Navigation logs will be disabled
  ///
  /// This method:
  /// 1. Registers the router as a singleton
  /// 2. Creates and registers an [AppNavigator] instance
  ///
  /// Example:
  /// ```dart
  /// void configureInjectionApp() {
  ///   // With navigation logs enabled (default)
  ///   getIt.registerAppRouter<AppRouter>(AppRouter());
  ///
  ///   // With navigation logs disabled
  ///   getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: false);
  /// }
  /// ```
  ///
  /// Note: The router registration is skipped if it's already registered
  /// or if the provided router is null.
  void registerAppRouter<T extends BaseAppRouter>(T? router,
      {bool enableNavigationLogs = true}) {
    try {
      if (router == null) {
        throw ArgumentError('Router cannot be null');
      }

      if (!isRegistered<T>()) {
        registerLazySingleton<BaseAppRouter>(() => get<T>());
        registerLazySingleton<AppNavigator>(() =>
            AppNavigator(get<T>(), enableNavigationLogs: enableNavigationLogs));
      }
    } catch (e) {
      throw 'Failed to register router: $e';
    }
  }
}
