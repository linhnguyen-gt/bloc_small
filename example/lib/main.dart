import 'package:bloc_small_example/navigation/app_router.dart';
import 'package:flutter/material.dart';

import 'di/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjectionApp(); // Initialize both core and app dependencies
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router.config(),
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
    );
  }
}
