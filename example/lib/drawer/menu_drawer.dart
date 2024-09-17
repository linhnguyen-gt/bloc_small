import 'package:flutter/material.dart';

import '../home.dart';
import '../reactive_subject/action_with_latest_context.dart';
import '../reactive_subject/combined_form_validation.dart';
import '../reactive_subject/debounced_search.dart';
import '../reactive_subject/default_settings.dart';
import '../reactive_subject/distinct_api_calls.dart';
import '../reactive_subject/email_filter.dart';
import '../reactive_subject/notification_merger.dart';
import '../reactive_subject/rate_limited_button.dart';
import '../reactive_subject/shopping_cart.dart';
import '../reactive_subject/stock_price.dart';
import '../reactive_subject/temperature_converter.dart';
import '../search_page.dart';
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
            routeName: MyHomePage.route,
            currentRoute: currentRoute,
            icon: const Icon(Icons.home),
          ),
          MenuItemWidget(
            caption: 'Search Page',
            routeName: SearchPage.route,
            currentRoute: currentRoute,
            icon: const Icon(Icons.search),
          ),
          const Divider(),
          MenuItemWidget(
            caption: 'Action With Latest Context (withLatestFrom)',
            routeName: ActionWithLatestContext.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Combined Form Validation (combineLatest)',
            routeName: CombinedFormValidation.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Debounced Search (debounceTime & switchMap)',
            routeName: DebouncedSearch.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Default Settings (startWith)',
            routeName: DefaultSettings.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Distinct Api Calls (distinct)',
            routeName: DistinctApiCalls.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Email Filter (where)',
            routeName: EmailFilter.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Notification Merger (merge)',
            routeName: NotificationMerger.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Rate Limited Button (throttleTime)',
            routeName: RateLimitedButton.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Shopping Cart (scan)',
            routeName: ShoppingCart.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Stock Price (switchMap)',
            routeName: StockPrice.route,
            currentRoute: currentRoute,
          ),
          MenuItemWidget(
            caption: 'Temperature Converter (map)',
            routeName: TemperatureConverter.route,
            currentRoute: currentRoute,
          ),
        ],
      ),
    );
  }
}
