import 'package:auto_route/auto_route.dart';

/// The navigation surface pages depend on.
///
/// Depend on this rather than the concrete `AppNavigator` so navigation can be
/// faked in widget tests. The DI container registers `AppNavigator` under this
/// type as well as its own.
///
/// Every method returns a non-nullable future. They were previously nullable
/// only because the internal "router missing" helper returned `void` rather
/// than `Never`, so flow analysis could not see it as terminating — the
/// nullability carried no meaning for callers.
abstract class INavigator {
  /// Pushes a new route onto the navigation stack.
  ///
  /// Completes with the result value when the pushed route is popped.
  Future<T?> push<T extends Object?>(PageRouteInfo route);

  /// Replaces the current route with a new one.
  Future<T?> replace<T extends Object?>(PageRouteInfo route);

  /// Pops the current route, optionally returning [result].
  ///
  /// Completes with whether a route was actually popped.
  Future<bool> pop<T extends Object?>([T? result]);

  /// Pops the top-most route in the router hierarchy.
  Future<bool> popTop<T extends Object?>([T? result]);

  /// Pops routes until [route] is at the top of the stack.
  ///
  /// The target route keeps its existing instance and state.
  Future<void> popUntil(PageRouteInfo route);

  /// Replaces every route in the stack with [route].
  Future<void> replaceAllWith(PageRouteInfo route);

  /// Clears the navigation stack and shows [route] as its only entry.
  Future<void> clearAndPush(PageRouteInfo route);
}
