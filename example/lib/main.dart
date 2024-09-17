import 'package:bloc_small_example/reactive_subject/action_with_latest_context.dart';
import 'package:bloc_small_example/reactive_subject/combined_form_validation.dart';
import 'package:bloc_small_example/reactive_subject/debounced_search.dart';
import 'package:bloc_small_example/reactive_subject/default_settings.dart';
import 'package:bloc_small_example/reactive_subject/distinct_api_calls.dart';
import 'package:bloc_small_example/reactive_subject/email_filter.dart';
import 'package:bloc_small_example/reactive_subject/notification_merger.dart';
import 'package:bloc_small_example/reactive_subject/rate_limited_button.dart';
import 'package:bloc_small_example/reactive_subject/shopping_cart.dart';
import 'package:bloc_small_example/reactive_subject/stock_price.dart';
import 'package:bloc_small_example/reactive_subject/temperature_converter.dart';
import 'package:bloc_small_example/search_page.dart';
import 'package:flutter/material.dart';

import 'di/di.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjectionApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: MyHomePage(),
      routes: {
        MyHomePage.route: (context) => MyHomePage(),
        SearchPage.route: (context) => SearchPage(),
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
      },
    );
  }
}
