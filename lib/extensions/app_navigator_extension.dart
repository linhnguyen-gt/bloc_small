import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../navigation/i_navigator.dart';

/// Extension on [GetIt] to provide type-safe access to the navigator.
///
/// This extension adds a convenient method to safely retrieve the [INavigator]
/// implementation from the dependency injection container.
extension AppNavigatorExtension on GetIt {
  /// Retrieves the [INavigator] implementation from the DI container.
  ///
  /// This method provides a type-safe way to access the navigation service.
  /// It includes built-in error checking to ensure the navigator is properly registered.
  ///
  /// Returns:
  ///   - [INavigator]: The registered navigator instance
  ///
  /// Throws:
  ///   - [FlutterError]: If no navigator is registered in the DI container
  ///
  /// Example:
  /// ```dart
  /// // Access navigator from anywhere
  /// final navigator = getIt.getNavigator();
  ///
  /// // Use it for navigation
  /// navigator.push(const HomeRoute());
  /// ```
  INavigator getNavigator() {
    if (!isRegistered<INavigator>()) {
      throw FlutterError(
        'AppNavigator not found in DI container.\n'
        'Did you forget to register AppRouter?\n\n'
        'Add this in your configureInjectionApp():\n'
        '  getIt.registerAppRouter<AppRouter>(AppRouter());',
      );
    }
    return get<INavigator>();
  }
}
