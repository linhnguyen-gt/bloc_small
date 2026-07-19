import 'package:bloc_small/bloc_small.dart';

import 'app_router.gr.dart';
import 'package:auto_route/auto_route.dart';

// No @LazySingleton here: `getIt.registerAppRouter<AppRouter>(AppRouter())`
// registers the instance it is handed, so annotating the router for codegen as
// well would register it twice and make `getIt.init()` throw.
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends BaseAppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MyHomeRoute.page, initial: true),
    AutoRoute(page: SearchRoute.page),
    AutoRoute(page: ReactiveSubjectScreen.page),
    AutoRoute(page: CounterRoute.page),
  ];
}
