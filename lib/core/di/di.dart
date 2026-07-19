import 'package:get_it/get_it.dart';

import '../../../navigation/app_navigator.dart';
import '../../../navigation/i_navigator.dart';
import '../../presentation/base/base_app_router.dart';
import '../../presentation/bloc/common_bloc.dart';

/// Raised when core dependency registration cannot be completed.
///
/// Carries the original [cause] so the stack trace survives — the previous
/// implementation threw a bare `String`, which loses both the type and the
/// trace at the point of failure.
class DependencyRegistrationException implements Exception {
  final String message;
  final Object? cause;

  DependencyRegistrationException(this.message, [this.cause]);

  @override
  String toString() =>
      'DependencyRegistrationException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

extension CoreInjection on GetIt {
  /// Registers core dependencies if they haven't been registered yet.
  ///
  /// [CommonBloc] is registered as a **lazy singleton**: it holds app-wide
  /// loading state, so every page must observe the same instance. A factory
  /// registration hands each caller its own instance, and a `showLoading()` on
  /// one is invisible to the widget rendering another.
  ///
  /// This is the only registration path for [CommonBloc]. It is deliberately
  /// not an `@module` — `injectable`'s code generator does not scan modules
  /// declared inside a *package*, only those in the consuming app, so a
  /// module here would never appear in a consumer's generated config.
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
        registerLazySingleton<CommonBloc>(CommonBloc.new);
      }
    } catch (e) {
      throw DependencyRegistrationException(
        'Failed to register core dependencies',
        e,
      );
    }
  }

  /// Unregisters the core dependencies registered by [registerCore].
  ///
  /// Intended for tests and hot restart, where re-running DI setup would
  /// otherwise throw "already registered". Closes the [CommonBloc] before
  /// dropping it so its stream controller is not leaked.
  Future<void> resetCore() async {
    if (isRegistered<CommonBloc>()) {
      await get<CommonBloc>().close();
      await unregister<CommonBloc>();
    }
  }

  /// Registers the app router and navigator for navigation management.
  ///
  /// Parameters:
  /// - [router]: The router instance that extends [BaseAppRouter]
  /// - [enableNavigationLogs]: Controls whether navigation logs are printed
  ///
  /// This method:
  /// 1. Registers [router] itself under both `T` and [BaseAppRouter]
  /// 2. Creates and registers an [AppNavigator] wrapping it, under both its own
  ///    type and [INavigator]
  ///
  /// Example:
  /// ```dart
  /// void configureInjectionApp() {
  ///   getIt.registerAppRouter<AppRouter>(AppRouter());
  ///
  ///   // With navigation logs disabled
  ///   getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: false);
  /// }
  /// ```
  ///
  /// Each registration is guarded independently, so calling this after some
  /// other setup has already registered one of the three types is safe.
  void registerAppRouter<T extends BaseAppRouter>(
    T? router, {
    bool enableNavigationLogs = true,
  }) {
    if (router == null) {
      throw ArgumentError.notNull('router');
    }

    try {
      // Register the instance we were handed. Previously the argument was
      // discarded and the body registered `() => get<T>()`, resolving a T that
      // nothing had registered — so even the happy path threw.
      if (!isRegistered<T>()) {
        registerSingleton<T>(router);
      }
      if (!isRegistered<BaseAppRouter>()) {
        registerLazySingleton<BaseAppRouter>(() => get<T>());
      }
      if (!isRegistered<AppNavigator>()) {
        registerLazySingleton<AppNavigator>(
          () => AppNavigator(
            get<BaseAppRouter>(),
            enableNavigationLogs: enableNavigationLogs,
          ),
        );
      }
      // Also expose it behind the interface so consumers can resolve — and
      // fake — navigation without depending on the concrete type.
      if (!isRegistered<INavigator>()) {
        registerLazySingleton<INavigator>(() => get<AppNavigator>());
      }
    } catch (e) {
      throw DependencyRegistrationException('Failed to register router', e);
    }
  }
}
