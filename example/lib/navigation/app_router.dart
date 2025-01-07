import 'package:auto_route/auto_route.dart';
import 'package:bloc_small/base/base_app_router.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@LazySingleton()
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
