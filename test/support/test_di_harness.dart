import 'package:bloc_small/bloc_small.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared GetIt lifecycle for DI-sensitive tests.
///
/// Every C-level DI defect in this release only reproduces under one of the two
/// registration lifetimes, and the example app only ever exercised `factory` —
/// which is precisely why C3/C6 stayed hidden. These helpers let a single test
/// body assert against both.
///
/// [GetIt.I.reset] runs in `tearDown` unconditionally: leaked registrations
/// across tests are what make DI bugs invisible (B3).
void useCleanGetIt() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });
}

/// The two registration lifetimes under test.
enum RegistrationStyle { singleton, factory }

extension TestRegistration on GetIt {
  /// Registers [factoryFn] under [T] using the given [style].
  ///
  /// Lets one test body run the same assertions against both lifetimes rather
  /// than duplicating the case per style.
  void registerWithStyle<T extends Object>(
    RegistrationStyle style,
    T Function() factoryFn,
  ) {
    switch (style) {
      case RegistrationStyle.singleton:
        registerLazySingleton<T>(factoryFn);
      case RegistrationStyle.factory:
        registerFactory<T>(factoryFn);
    }
  }
}

/// Registers the package's core dependencies plus [factoryFn] under [T].
///
/// Mirrors what a consumer app's `configureInjectionApp()` does, so DI tests
/// exercise the real registration path rather than a hand-rolled one.
void registerCoreAnd<T extends Object>(
  RegistrationStyle style,
  T Function() factoryFn,
) {
  GetIt.I.registerCore();
  GetIt.I.registerWithStyle<T>(style, factoryFn);
}
