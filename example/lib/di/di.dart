import 'package:bloc_small/bloc_small.dart';

import '../navigation/app_router.dart';
import 'di.config.dart';

// The global instance of GetIt for dependency injection
final getIt = GetIt.instance;

@injectableInit
void configureInjectionApp() {
  // Step 1 (Optional): Register your preferred navigation solution
  // Example with AppRouter:
  getIt.registerAppRouter<AppRouter>(AppRouter(), enableNavigationLogs: true);

  // Step 2: Register other dependencies
  getIt.registerCore();

  // Step 3: Initialize injectable
  getIt.init();
}
