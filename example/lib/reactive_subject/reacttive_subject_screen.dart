import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import 'action_with_latest_context.dart';
import 'combined_form_validation.dart';
import 'debounced_search.dart';
import 'default_settings.dart';
import 'distinct_api_calls.dart';
import 'email_filter.dart';
import 'notification_merger.dart';
import 'rate_limited_button.dart';
import 'shopping_cart.dart';
import 'stock_price.dart';
import 'temperature_converter.dart';
import 'api_retry_example.dart';

@RoutePage()
class ReactiveSubjectScreen extends StatelessWidget {
  const ReactiveSubjectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactive Subject',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ActionWithLatestContext(),
      routes: {
        ActionWithLatestContext.route: (context) => ActionWithLatestContext(),
        CombinedFormValidation.route: (context) => CombinedFormValidation(),
        DebouncedSearch.route: (context) => DebouncedSearch(),
        DefaultSettings.route: (context) => DefaultSettings(),
        DistinctApiCalls.route: (context) => DistinctApiCalls(),
        EmailFilter.route: (context) => EmailFilter(),
        NotificationMerger.route: (context) => NotificationMerger(),
        RateLimitedButton.route: (context) => RateLimitedButton(),
        ShoppingCart.route: (context) => ShoppingCart(),
        StockPrice.route: (context) => StockPrice(),
        TemperatureConverter.route: (context) => TemperatureConverter(),
        ApiRetryExample.route: (context) => ApiRetryExample(),
      },
    );
  }
}
