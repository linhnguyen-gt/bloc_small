import 'package:flutter/material.dart';

import '../navigation/app_router.gr.dart';
import 'menu_item.dart';

class MenuDrawer extends StatelessWidget {
  final String currentRoute;

  const MenuDrawer(this.currentRoute);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          MenuItemWidget(
            caption: 'Home',
            route: MyHomeRoute(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.home),
          ),
          MenuItemWidget(
            caption: 'Search Page',
            route: SearchRoute(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.search),
          ),
          const Divider(),
          MenuItemWidget(
            caption: 'Reactive Subject',
            route: ReactiveSubjectScreen(),
            currentRoute: currentRoute,
            icon: const Icon(Icons.stream),
          ),
          // MenuItemWidget(
          //   caption: 'Action With Latest Context (withLatestFrom)',
          //   routeName: ActionWithLatestContext.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Combined Form Validation (combineLatest)',
          //   routeName: CombinedFormValidation.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Debounced Search (debounceTime & switchMap)',
          //   routeName: DebouncedSearch.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Default Settings (startWith)',
          //   routeName: DefaultSettings.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Distinct Api Calls (distinct)',
          //   routeName: DistinctApiCalls.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Email Filter (where)',
          //   routeName: EmailFilter.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Notification Merger (merge)',
          //   routeName: NotificationMerger.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Rate Limited Button (throttleTime)',
          //   routeName: RateLimitedButton.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Shopping Cart (scan)',
          //   routeName: ShoppingCart.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Stock Price (switchMap)',
          //   routeName: StockPrice.route,
          //   currentRoute: currentRoute,
          // ),
          // MenuItemWidget(
          //   caption: 'Temperature Converter (map)',
          //   routeName: TemperatureConverter.route,
          //   currentRoute: currentRoute,
          // ),
        ],
      ),
    );
  }
}
