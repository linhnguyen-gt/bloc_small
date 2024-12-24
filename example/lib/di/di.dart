import 'package:bloc_small/bloc_small.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

@InjectableInit()
void configureInjectionApp() {
  // Step 1: Register core dependencies from package bloc_small
  getIt.registerCore();

  // Step 2: Register your app dependencies
  getIt.init();
}
