library;

import 'package:flutter_bloc/flutter_bloc.dart';

// Only the third-party types that appear in this package's own public
// signatures are re-exported.
//
// Previously `auto_route`, `flutter_bloc`, `freezed_annotation`, `get_it` and
// `injectable` were re-exported wholesale. That had two costs:
//   - `flutter_bloc` transitively re-exports `provider`, so importing this
//     package alongside `package:provider/provider.dart` produced ambiguity
//     errors on names like `ReadContext`. `injectable`'s `test` annotation
//     collided with `flutter_test`'s `test` function in the same way.
//   - any breaking change in those packages silently became a breaking change
//     here, with no version bump of our own.
//
// Consumers now import what they use directly. See the 4.0.0 migration notes.
export 'package:auto_route/auto_route.dart' show AutoRoute, PageRouteInfo;
export 'package:flutter_bloc/flutter_bloc.dart'
    show
        Bloc,
        BlocBuilder,
        BlocConsumer,
        BlocListener,
        BlocProvider,
        Cubit,
        Emitter,
        MultiBlocListener,
        MultiBlocProvider,
        StateStreamableSource;
export 'package:get_it/get_it.dart' show GetIt;

// Domain barrel files
export 'core/core.dart';
export 'extensions/extensions.dart';
export 'navigation/navigation.dart';
export 'presentation/presentation.dart';

typedef BlocEventHandler<E, S> =
    Future<void> Function(E event, Emitter<S> emit);
typedef BlocErrorHandler =
    Future<void> Function(Object error, StackTrace stack);
