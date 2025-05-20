library;

// Core exports
import 'dart:developer' as developer;
import 'dart:io';

import 'bloc_small.dart';

export 'package:auto_route/auto_route.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
// Freezed
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:get_it/get_it.dart';
export 'package:injectable/injectable.dart';

// Constants
export 'core/constants/default_loading.dart';
// Core layer
// DI
export 'core/di/di.dart';
// Error handling
export 'core/error/bloc_error_handler.dart';
export 'core/error/cubit_error_handler.dart';
export 'core/error/error_state.dart';
export 'core/error/exceptions.dart';
// Extensions
export 'core/extensions/app_navigator_extension.dart';
export 'core/extensions/bloc_context_extension.dart';
// Utils
export 'core/utils/reactive_subject.dart';
// Navigation
export 'navigation/app_navigator.dart';
export 'navigation/i_navigator.dart';
// Presentation layer
// Base classes
export 'presentation/base/base_app_router.dart';
export 'presentation/base/base_bloc_page.dart';
export 'presentation/base/base_bloc_page_state.dart';
export 'presentation/base/base_cubit_page.dart';
export 'presentation/base/base_cubit_state.dart';
export 'presentation/base/base_page_delegate.dart';
export 'presentation/base/base_page_stateless_delegate.dart';
// Bloc
export 'presentation/bloc/common_bloc.dart';
export 'presentation/bloc/main_bloc.dart';
export 'presentation/bloc/main_bloc_event.dart';
export 'presentation/bloc/main_bloc_state.dart';
// Cubit
export 'presentation/cubit/main_cubit.dart';
// Widgets
export 'presentation/widgets/loading_indicator.dart';

typedef BlocEventHandler<E, S> =
    Future<void> Function(E event, Emitter<S> emit);
typedef BlocErrorHandler =
    Future<void> Function(Object error, StackTrace stack);

void checkCompatibility() {
  if (Platform.version.startsWith('2')) {
    developer.log(
      'Warning: bloc_small requires Dart 3.0 or higher for best performance',
    );
  }
}
