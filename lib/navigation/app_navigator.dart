import 'package:auto_route/auto_route.dart';

import '../base/base_app_router.dart';
import 'i_navigator.dart';

/// Handles navigation operations using auto_route
class AppNavigator implements INavigator {
  /// Creates an [AppNavigator] instance with the provided [BaseAppRouter]
  const AppNavigator(this._appRouter);

  /// The router instance used for navigation
  final BaseAppRouter _appRouter;

  /// Pushes a new route onto the navigation stack
  ///
  /// Returns a Future that completes with the result value when the pushed route is popped
  @override
  Future<T?>? push<T extends Object?>(PageRouteInfo route) =>
      _appRouter.push<T>(route);

  /// Replaces the current route with a new one
  ///
  /// Returns a Future that completes with the result value when the new route is popped
  @override
  Future<T?>? replace<T extends Object?>(PageRouteInfo route) =>
      _appRouter.replace<T>(route);

  /// Pops the current route off the navigation stack
  ///
  /// If [result] is provided, it will be passed to the previous route
  /// Returns a Future<bool> indicating whether the pop was successful
  @override
  Future<bool>? pop<T extends Object?>([T? result]) =>
      _appRouter.maybePop<T>(result);

  /// Pops all routes until reaching the specified route
  ///
  /// The specified route will be pushed onto the stack
  @override
  Future<void>? popUntil(PageRouteInfo route) =>
      _appRouter.pushAndPopUntil(route, predicate: (_) => false);

  @override
  Future<bool>? popTop<T extends Object?>([T? result]) {
    return _appRouter.maybePopTop();
  }

  /// Replaces all routes in the stack with a single new route
  ///
  /// This effectively resets the navigation stack with only the specified route
  @override
  Future<void> replaceAllWith(PageRouteInfo route) =>
      _appRouter.replaceAll([route]);

  /// Clears the entire navigation stack and pushes a new route
  ///
  /// This is equivalent to [replaceAllWith] in the current implementation
  @override
  Future<void> clearAndPush(PageRouteInfo route) {
    _appRouter.replaceAll([route]);
    return _appRouter.push(route);
  }
}