import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../navigation/app_navigator.dart';

/// Extension on [GetIt] to provide type-safe access to [AppNavigator].
///
/// This extension adds a convenient method to safely retrieve the [AppNavigator]
/// instance from the dependency injection container.
extension AppNavigatorExtension on GetIt {
  /// Retrieves the [AppNavigator] instance from the DI container.
  ///
  /// This method provides a type-safe way to access the navigation service.
  /// It includes built-in error checking to ensure the navigator is properly registered.
  ///
  /// Returns:
  ///   - [AppNavigator]: The registered navigator instance
  ///
  /// Throws:
  ///   - [FlutterError]: If [AppNavigator] is not registered in the DI container
  ///
  /// Example:
  /// ```dart
  /// // Access navigator from anywhere
  /// final navigator = getIt.getNavigator();
  ///
  /// // Use it for navigation
  /// navigator.push(const HomeRoute());
  /// ```
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
