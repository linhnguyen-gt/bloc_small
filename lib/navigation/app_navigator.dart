import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../presentation/base/base_app_router.dart';
import 'i_navigator.dart';

/// Handles navigation operations using auto_route.
class AppNavigator implements INavigator {
  /// Creates an [AppNavigator] instance with the provided [BaseAppRouter]
  const AppNavigator(this._appRouter, {this.enableNavigationLogs = true});

  /// The router instance used for navigation
  final BaseAppRouter? _appRouter;

  /// Controls whether navigation logs are printed
  final bool enableNavigationLogs;

  /// Returns the router, or reports the missing registration and never returns.
  ///
  /// Typed `Never` on the throwing path so callers do not have to treat every
  /// return value as nullable just because the router might be absent.
  BaseAppRouter get _router {
    final router = _appRouter;
    if (router == null) {
      throw FlutterError(
        'AppNavigator not found in DI container.\n'
        'Did you forget to register AppRouter?\n\n'
        'Add this in your configureInjectionApp():\n'
        '  getIt.registerAppRouter<AppRouter>(AppRouter());',
      );
    }
    return router;
  }

  void _log(String message) {
    if (enableNavigationLogs) {
      developer.log(message);
    }
  }

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route) {
    _log('push route: ${route.routeName}');
    return _router.push<T>(route);
  }

  @override
  Future<T?> replace<T extends Object?>(PageRouteInfo route) {
    _log('replace route: ${route.routeName}');
    return _router.replace<T>(route);
  }

  @override
  Future<bool> pop<T extends Object?>([T? result]) {
    _log('pop route: ${result.runtimeType}');
    return _router.maybePop<T>(result);
  }

  @override
  Future<bool> popTop<T extends Object?>([T? result]) {
    _log('popTop route: ${result.runtimeType}');
    return _router.maybePopTop();
  }

  /// Pops routes until [route] is at the top of the stack.
  ///
  /// The target route keeps its existing instance, so its state survives and
  /// the `Future` returned by the original `push` completes. The previous
  /// implementation used `pushAndPopUntil(route, predicate: (_) => false)`,
  /// which removed *every* route including the target and pushed a fresh one —
  /// discarding its state and leaving the original push future to hang.
  @override
  Future<void> popUntil(PageRouteInfo route) async {
    _log('popUntil route: ${route.routeName}');
    _router.popUntilRouteWithName(route.routeName);
  }

  @override
  Future<void> replaceAllWith(PageRouteInfo route) {
    _log('replaceAllWith route: ${route.routeName}');
    return _router.replaceAll([route]);
  }

  /// Clears the entire navigation stack and shows [route] as its only entry.
  ///
  /// Equivalent to [replaceAllWith], as the documentation has always claimed.
  /// The previous implementation also pushed [route] a second time, leaving two
  /// entries on the stack so that "back" reached a duplicate instead of exiting.
  @override
  Future<void> clearAndPush(PageRouteInfo route) {
    _log('clearAndPush route: ${route.routeName}');
    return _router.replaceAll([route]);
  }
}
