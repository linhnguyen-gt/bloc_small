import 'package:bloc_small/bloc_small.dart';
import 'package:injectable/injectable.dart';

import '../navigation/app_router.dart';
import 'di.config.dart';

// The global instance of GetIt for dependency injection
final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureInjectionApp() {
  // Step 1 (Optional): Register your preferred navigation solution
  // Example with AppRouter:
  getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: true);

  // Step 2: Register other dependencies
  getIt.registerCore();

  // Step 3: Initialize injectable
  getIt.init();
}
