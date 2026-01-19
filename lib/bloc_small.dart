library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

// Package exports
export 'package:auto_route/auto_route.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:get_it/get_it.dart';
export 'package:injectable/injectable.dart';

// Domain barrel files
export 'core/core.dart';
export 'extensions/extensions.dart';
export 'navigation/navigation.dart';
export 'presentation/presentation.dart';

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
