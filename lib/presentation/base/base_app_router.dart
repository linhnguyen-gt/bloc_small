import 'package:auto_route/auto_route.dart';

/// Base class for implementing application routing using auto_route.
///
/// This abstract class provides a foundation for implementing routing in your application
/// using the auto_route package. It sets up basic routing configuration and can be extended
/// to create specific routing implementations.
///
/// Example usage:
/// ```dart
/// @AutoRouterConfig()
/// class AppRouter extends BaseAppRouter {
///   @override
///   List<AutoRoute> get routes => [
///     AutoRoute(page: HomeRoute.page, initial: true),
///     AutoRoute(page: SettingsRoute.page),
///     // Add more routes here
///   ];
/// }
/// ```
///
/// Features:
/// - Provides a default navigator key for route management
/// - Sets up adaptive routing by default (supports different platforms)
/// - Can be extended to implement custom routing logic
///
/// Note: This class is designed to work with auto_route package.
/// For best results, use with the following setup:
/// 1. Extend this class
/// 2. Add @AutoRouterConfig() annotation
/// 3. Add @LazySingleton() annotation to dependency injection
/// 4. Override the routes getter
/// 5. Register your router in dependency injection
abstract class BaseAppRouter extends RootStackRouter {
  BaseAppRouter() : super();

  /// Defines the default route type as adaptive.
  ///
  /// This means the routing behavior will adapt based on the platform
  /// (e.g., different transitions for iOS and Android).
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  /// Override this to define your application's routes.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// List<AutoRoute> get routes => [
  ///   AutoRoute(page: HomeRoute.page, initial: true),
  ///   AutoRoute(page: LoginRoute.page),
  /// ];
  /// ```
  @override
  List<AutoRoute> get routes => [];
}
