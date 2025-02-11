import 'package:get_it/get_it.dart';

void configureDependencies() {
  GetIt.I.registerSingleton<GetIt>(GetIt.instance);
}
