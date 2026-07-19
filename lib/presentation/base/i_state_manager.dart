import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../navigation/i_navigator.dart';
import '../bloc/common_bloc.dart';

/// The contract a page's state manager must satisfy to be driven by a base page.
///
/// Base pages need two things from their `B` type parameter at once: it must be
/// providable to `BlocProvider<B>` (hence [StateStreamableSource]), and it must
/// accept the wiring the delegate performs. Dart has no intersection type
/// bounds, so `B extends StateStreamableSource<S> & BaseDelegate<S>` cannot be
/// written — this interface unifies both requirements into a single bound and
/// removes the `di<B>() as dynamic` cast that previously stood in for it.
///
/// [MainBloc] and [MainCubit] implement this; consumers get it by extending
/// either, and are not expected to implement it directly.
abstract interface class IStateManager<S> implements StateStreamableSource<S> {
  /// Injects the app-wide loading-state bloc.
  ///
  /// Assigning more than once is safe: a state manager outlives the pages that
  /// wire it, so re-pushing a page re-runs this setter on the same instance.
  set commonBloc(CommonBloc bloc);

  /// Injects the navigator, or `null` when no router is registered.
  set navigator(INavigator? navigator);
}

/// Verifies that [T] is registered with a lifetime the page family supports.
///
/// Only singleton and lazy-singleton registrations are valid for a page's
/// state manager. A factory hands every resolution its own instance, and since
/// pages provide the instance with `BlocProvider.value` and never close it,
/// nothing would ever dispose those instances — GetIt does not track them.
///
/// Runs only in debug builds; the body is compiled out of release.
void debugAssertSingletonRegistration<T extends Object>(GetIt di) {
  assert(() {
    if (!di.isRegistered<T>()) {
      return true;
    }
    // GetIt has no public lifetime query, so probe it: two resolutions of a
    // factory return different instances, a singleton returns the same one.
    if (identical(di<T>(), di<T>())) {
      return true;
    }
    throw StateError(
      '$T is registered as a factory, which is not supported for a page\'s '
      'state manager.\n'
      'Pages provide it with BlocProvider.value and never close it, so a '
      'factory instance would leak on every page build.\n'
      'Register it with registerSingleton/registerLazySingleton instead '
      '(or @singleton / @lazySingleton with injectable).',
    );
  }());
}
