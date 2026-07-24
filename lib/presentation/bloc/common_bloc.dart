import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/default_loading.dart';
import 'main_bloc.dart';
import 'main_bloc_event.dart';
import 'main_bloc_state.dart';

part 'common_event.dart';
part 'common_state.dart';

class CommonBloc extends MainBloc<CommonEvent, CommonState> {
  CommonBloc() : super(const CommonState()) {
    on<SetComponentLoading>(_onSetComponentLoading);
    on<ClearComponentLoading>(_onClearComponentLoading);
  }

  /// Adjusts the reference count for a loading key.
  ///
  /// Counting rather than storing a boolean is what makes overlapping
  /// operations correct: with a flag, the first of two concurrent operations
  /// to finish cleared the spinner while the second was still running.
  ///
  /// The count floors at zero, so an unmatched hide cannot drive it negative
  /// and strand a later show. Keys are removed once they reach zero — leaving
  /// them behind leaked one map entry per operation for the app's lifetime
  /// when keys were derived per item.
  FutureOr<void> _onSetComponentLoading(
    SetComponentLoading event,
    Emitter<CommonState> emit,
  ) {
    final updated = Map<String, int>.from(state.loadingStates);
    final current = updated[event.key] ?? 0;

    if (event.isLoading) {
      updated[event.key] = current + 1;
    } else if (current <= 1) {
      updated.remove(event.key);
    } else {
      updated[event.key] = current - 1;
    }

    emit(state.copyWith(loadingStates: updated));
  }

  /// Force-clears a loading key regardless of its count.
  ///
  /// The safety timeout needs this: a single decrement cannot clear a key held
  /// by two or more operations, so under refcounting the runaway-spinner
  /// escape hatch would silently stop working in exactly the concurrent case
  /// that motivated refcounting.
  FutureOr<void> _onClearComponentLoading(
    ClearComponentLoading event,
    Emitter<CommonState> emit,
  ) {
    if (!state.loadingStates.containsKey(event.key)) {
      return null;
    }
    final updated = Map<String, int>.from(state.loadingStates)
      ..remove(event.key);
    emit(state.copyWith(loadingStates: updated));
  }
}
