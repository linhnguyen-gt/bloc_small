import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';
import '../di/di.dart';

import '../navigation/app_router.gr.dart';
import 'action_with_latest_context.dart';
import 'combined_form_validation.dart';
import 'debounced_search.dart';
import 'default_settings.dart';
import 'distinct_api_calls.dart';
import 'email_filter.dart';
import 'notification_merger.dart';
import 'rate_limited_button.dart';
import 'reactive_subject_menu_item.dart';
import 'shopping_cart.dart';
import 'stock_price.dart';
import 'temperature_converter.dart';
import 'api_retry_example.dart';

class ReactiveSubjectDrawer extends StatelessWidget {
  final String currentRoute;

  const ReactiveSubjectDrawer(this.currentRoute);

  @override
  Widget build(BuildContext context) {
    final navigator = getIt.getNavigator();

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: GestureDetector(
              onTap: () {
                navigator.replaceAllWith(MyHomeRoute());
              },
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Action With Latest Context (withLatestFrom)',
            routeName: ActionWithLatestContext.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Combined Form Validation (combineLatest)',
            routeName: CombinedFormValidation.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Debounced Search (debounceTime & switchMap)',
            routeName: DebouncedSearch.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Default Settings (startWith)',
            routeName: DefaultSettings.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Distinct Api Calls (distinct)',
            routeName: DistinctApiCalls.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Email Filter (where)',
            routeName: EmailFilter.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Notification Merger (merge)',
            routeName: NotificationMerger.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Rate Limited Button (throttleTime)',
            routeName: RateLimitedButton.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Shopping Cart (scan)',
            routeName: ShoppingCart.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Stock Price (switchMap)',
            routeName: StockPrice.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'Temperature Converter (map)',
            routeName: TemperatureConverter.route,
            currentRoute: currentRoute,
          ),
          ReactiveSubjectMenuItemWidget(
            caption: 'API Retry Example (Error Handling)',
            routeName: ApiRetryExample.route,
            currentRoute: currentRoute,
          ),
        ],
      ),
    );
  }
}
