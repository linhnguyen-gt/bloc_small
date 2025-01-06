import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../navigation/app_navigator.dart';

extension AppNavigatorExtension on GetIt {
  AppNavigator getNavigator() {
    if (!isRegistered<AppNavigator>()) {
      throw FlutterError('AppNavigator not found in DI container.\n'
          'Did you forget to register AppRouter?\n\n'
          'Add this in your configureInjectionApp():\n'
          '  getIt.registerAppRouter<AppRouter>(AppRouter());');
    }
    return get<AppNavigator>();
  }
}
