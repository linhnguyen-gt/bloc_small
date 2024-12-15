import 'package:bloc_small/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjectionApp() => getIt.init();
