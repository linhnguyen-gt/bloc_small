import 'package:auto_route/auto_route.dart';

abstract class INavigator {
  Future<T?>? push<T extends Object?>(PageRouteInfo route);
  Future<T?>? replace<T extends Object?>(PageRouteInfo route);
  Future<bool>? pop<T extends Object?>([T? result]);
  Future<bool>? popTop<T extends Object?>([T? result]);
  Future<void>? popUntil(PageRouteInfo route);
  Future<void>? replaceAllWith(PageRouteInfo route);
  Future<void>? clearAndPush(PageRouteInfo route);
}
