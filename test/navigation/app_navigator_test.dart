import 'package:auto_route/auto_route.dart';
import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the router calls [AppNavigator] makes.
///
/// I2 and I3 are both defects in *which router primitives get called*, so a
/// recording spy verifies them directly. Real stack semantics are exercised by
/// the example app (phase 8) rather than reconstructed here — standing up a
/// real auto_route stack needs generated routes.
class SpyAppRouter extends BaseAppRouter {
  final List<String> calls = <String>[];

  @override
  Future<T?> push<T extends Object?>(
    PageRouteInfo route, {
    OnNavigationFailure? onFailure,
  }) async {
    calls.add('push(${route.routeName})');
    return null;
  }

  @override
  Future<void> replaceAll(
    List<PageRouteInfo> routes, {
    bool updateExistingRoutes = true,
    OnNavigationFailure? onFailure,
  }) async {
    calls.add('replaceAll(${routes.map((r) => r.routeName).join(",")})');
  }

  @override
  Future<T?> pushAndPopUntil<T extends Object?>(
    PageRouteInfo route, {
    required RoutePredicate predicate,
    bool scopedPopUntil = true,
    OnNavigationFailure? onFailure,
  }) async {
    calls.add('pushAndPopUntil(${route.routeName})');
    return null;
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    calls.add('maybePop');
    return true;
  }

  @override
  void popUntil(RoutePredicate predicate, {bool scoped = true}) {
    calls.add('popUntil');
  }

  @override
  void popUntilRouteWithName(String name, {bool scoped = true}) {
    calls.add('popUntilRouteWithName($name)');
  }
}

/// A hand-written navigator, standing in for what a consumer would supply in a
/// widget test. Only possible because [INavigator] is the injected type.
class FakeNavigator implements INavigator {
  final List<String> pushed = <String>[];

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route) async {
    pushed.add(route.routeName);
    return null;
  }

  @override
  Future<T?> replace<T extends Object?>(PageRouteInfo route) async => null;

  @override
  Future<bool> pop<T extends Object?>([T? result]) async => true;

  @override
  Future<bool> popTop<T extends Object?>([T? result]) async => true;

  @override
  Future<void> popUntil(PageRouteInfo route) async {}

  @override
  Future<void> replaceAllWith(PageRouteInfo route) async {}

  @override
  Future<void> clearAndPush(PageRouteInfo route) async {}
}

/// A route info that needs no codegen.
class FakeRoute extends PageRouteInfo<void> {
  const FakeRoute() : super(name, initialChildren: null);

  static const String name = 'FakeRoute';
}

void main() {
  late SpyAppRouter router;
  late AppNavigator navigator;

  setUp(() {
    router = SpyAppRouter();
    navigator = AppNavigator(router, enableNavigationLogs: false);
  });

  group('clearAndPush (I2)', () {
    // I2: the implementation calls replaceAll([route]) *then* push(route),
    // leaving [Home, Home] on the stack, so back goes to a second Home instead
    // of exiting. Its own doc says it is equivalent to replaceAllWith.
    test('I2: replaces the stack without an extra push', () async {
      await navigator.clearAndPush(const FakeRoute());

      expect(router.calls, equals(<String>['replaceAll(FakeRoute)']));
    });

    test('I2: matches replaceAllWith, as documented', () async {
      await navigator.clearAndPush(const FakeRoute());
      final clearAndPushCalls = List<String>.from(router.calls);

      router.calls.clear();
      await navigator.replaceAllWith(const FakeRoute());

      expect(clearAndPushCalls, equals(router.calls));
    });
  });

  group('popUntil (I3)', () {
    // I3: pushAndPopUntil(route, predicate: (_) => false) removes *every*
    // route including the target and pushes a fresh instance, losing the
    // original route's state and leaving its push future uncompleted.
    test('I3: pops to the existing route instead of pushing a new one', () async {
      await navigator.popUntil(const FakeRoute());

      expect(
        router.calls,
        isNot(contains('pushAndPopUntil(FakeRoute)')),
        reason: 'pushing a fresh instance discards the target route state',
      );
      expect(
        router.calls.single,
        anyOf(
          equals('popUntil'),
          equals('popUntilRouteWithName(FakeRoute)'),
        ),
      );
    });
  });

  group('INavigator injection (I21)', () {
    // The interface existed but nothing resolved it, so a fake could never be
    // picked up. It must now be the type the DI container hands out.
    test('I21: a fake navigator can be injected and resolved', () async {
      await GetIt.I.reset();
      addTearDown(GetIt.I.reset);

      final fake = FakeNavigator();
      GetIt.I.registerSingleton<INavigator>(fake);

      final resolved = GetIt.I.getNavigator();

      expect(identical(resolved, fake), isTrue);
      await resolved.push(const FakeRoute());
      expect(fake.pushed, equals(<String>['FakeRoute']));
    });

    test('I21: registerAppRouter registers AppNavigator behind INavigator', () async {
      await GetIt.I.reset();
      addTearDown(GetIt.I.reset);

      GetIt.I.registerAppRouter<SpyAppRouter>(SpyAppRouter());

      expect(GetIt.I<INavigator>(), isA<AppNavigator>());
      expect(identical(GetIt.I<INavigator>(), GetIt.I<AppNavigator>()), isTrue);
    });
  });

  group('return types', () {
    // Every method used to return a nullable Future purely because the
    // "router missing" helper was typed void instead of Never.
    test('navigation methods return non-nullable futures', () {
      final Future<void> clear = navigator.clearAndPush(const FakeRoute());
      final Future<bool> popped = navigator.pop();

      expect(clear, isA<Future<void>>());
      expect(popped, isA<Future<bool>>());
    });
  });

  group('error reporting', () {
    test('a missing router produces a FlutterError naming the fix', () {
      const orphan = AppNavigator(null, enableNavigationLogs: false);

      expect(
        () => orphan.push(const FakeRoute()),
        throwsA(
          isA<FlutterError>().having(
            (e) => e.message,
            'message',
            contains('registerAppRouter'),
          ),
        ),
      );
    });
  });
}
