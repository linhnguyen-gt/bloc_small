library bloc_small;

// Core exports
import 'dart:developer' as developer;
import 'dart:io';

import 'bloc_small.dart';

export 'package:auto_route/auto_route.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:get_it/get_it.dart';

// Base classes
export 'base/base_app_router.dart';
export 'base/base_bloc_page.dart';
export 'base/base_bloc_page_state.dart';
export 'base/base_cubit_page.dart';
export 'base/base_cubit_state.dart';
export 'base/base_page_delegate.dart';
// Common bloc
export 'bloc/common/common_bloc.dart';
// Bloc core
export 'bloc/core/bloc/main_bloc.dart';
export 'bloc/core/cubit/main_cubit.dart';
// DI
export 'bloc/core/di/di.dart';
// Error handling
export 'bloc/core/error/bloc_error_handler.dart';
export 'bloc/core/error/cubit_error_handler.dart';
export 'bloc/core/error/error_state.dart';
export 'bloc/core/error/exceptions.dart';
export 'bloc/core/main_bloc_event.dart';
export 'bloc/core/main_bloc_state.dart';
// Constants
export 'constant/default_loading.dart';
// Extensions
export 'extensions/app_navigator_extension.dart';
export 'extensions/bloc_context_extension.dart';
// Navigation
export 'navigation/app_navigator.dart';
export 'navigation/i_navigator.dart';
// Utils
export 'utils/reactive_subject.dart';

typedef BlocEventHandler<E, S> = Future<void> Function(
    E event, Emitter<S> emit);
typedef BlocErrorHandler = Future<void> Function(
    Object error, StackTrace stack);

void checkCompatibility() {
  if (Platform.version.startsWith('2')) {
    developer.log(
        'Warning: bloc_small requires Dart 3.0 or higher for best performance');
  }
}
