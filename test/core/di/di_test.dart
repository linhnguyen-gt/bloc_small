import 'package:bloc_small/bloc_small.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_di_harness.dart';

/// Minimal router stand-in. `registerAppRouter` only needs a `BaseAppRouter`
/// subtype; the routing behaviour itself is covered in the navigation suite.
class TestAppRouter extends BaseAppRouter {
  @override
  List<AutoRoute> get routes => const [];
}

void main() {
  useCleanGetIt();

  group('registerCore', () {
    // C4: post-D1 CommonBloc is an app-wide singleton. Today registerCore uses
    // registerFactory, so every resolution hands back a fresh instance and a
    // showLoading() mutates an instance no BlocProvider renders.
    test('C4: resolves the same CommonBloc instance every time', () {
      GetIt.I.registerCore();

      final first = GetIt.I<CommonBloc>();
      final second = GetIt.I<CommonBloc>();

      expect(identical(first, second), isTrue);
    });

    test('is idempotent — calling it twice does not throw', () {
      GetIt.I.registerCore();
      expect(GetIt.I.registerCore, returnsNormally);
    });

    // B3: without a reset hook, a second DI run after hot restart throws
    // "already registered".
    test('B3: resetCore allows re-registration', () async {
      GetIt.I.registerCore();
      await GetIt.I.resetCore();

      expect(GetIt.I.registerCore, returnsNormally);
      expect(GetIt.I.isRegistered<CommonBloc>(), isTrue);
    });
  });

  group('registerAppRouter', () {
    // I1: the `router` argument is discarded entirely. The body registers
    // `() => get<T>()`, but T is never registered anywhere, so resolving
    // BaseAppRouter or AppNavigator throws even on the happy path.
    test('I1: registers the router instance it is handed', () {
      final router = TestAppRouter();
      GetIt.I.registerAppRouter<TestAppRouter>(router);

      expect(identical(GetIt.I<BaseAppRouter>(), router), isTrue);
    });

    test('I1: AppNavigator resolves after registerAppRouter', () {
      GetIt.I.registerAppRouter<TestAppRouter>(TestAppRouter());

      expect(() => GetIt.I<AppNavigator>(), returnsNormally);
    });

    // I1 (order independence): a consumer calling getIt.init() before
    // registerAppRouter must still end up with a working navigator.
    test('I1: works regardless of call order relative to core registration', () {
      GetIt.I.registerCore();
      GetIt.I.registerAppRouter<TestAppRouter>(TestAppRouter());

      expect(() => GetIt.I<AppNavigator>(), returnsNormally);
      expect(() => GetIt.I<CommonBloc>(), returnsNormally);
    });

    // B2: a thrown String loses both type and stack trace.
    test('B2: a null router throws a typed error, not a String', () {
      expect(
        () => GetIt.I.registerAppRouter<TestAppRouter>(null),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
