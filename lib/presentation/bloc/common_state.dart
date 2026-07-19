part of 'common_bloc.dart';

/// Represents the state of common application-wide features.
///
/// This state manages loading indicators across the application using a key-based system.
/// Each loading operation can have its own unique key, allowing multiple loading states
/// to be tracked independently.
///
/// Example:
/// ```dart
/// // Check global loading state
/// final isGlobalLoading = state.isLoading();
///
/// // Check specific loading state
/// final isLoginLoading = state.isLoading(key: 'login');
/// ```
class CommonState extends MainBlocState {
  /// Reference counts of in-flight loading operations, keyed by identifier.
  ///
  /// The value is the number of operations currently holding that key, not a
  /// boolean: two overlapping operations on `'fetch'` store `2`, and the
  /// spinner stays up until both finish. A key is absent when nothing holds it
  /// — the map never retains zero entries.
  final Map<String, int> loadingStates;

  const CommonState({this.loadingStates = const {}});

  /// Checks if a loading operation is currently active.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the loading operation.
  ///   Defaults to [LoadingKey.global] if not specified.
  ///
  /// Returns `true` if the loading operation is active, `false` otherwise.
  bool isLoading({String? key = LoadingKey.global}) =>
      (loadingStates[key] ?? 0) > 0;

  /// Creates a copy of this state with the given fields replaced with new values.
  ///
  /// Parameters:
  /// - [loadingStates]: The new loading states map. If null, keeps the current value.
  ///
  /// Returns a new [CommonState] instance with updated values.
  CommonState copyWith({Map<String, int>? loadingStates}) {
    return CommonState(loadingStates: loadingStates ?? this.loadingStates);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! CommonState) {
      return false;
    }

    // Deep comparison of maps
    if (loadingStates.length != other.loadingStates.length) {
      return false;
    }
    for (final key in loadingStates.keys) {
      if (loadingStates[key] != other.loadingStates[key]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    // Combine per-entry hashes with XOR so the result does not depend on
    // iteration order. `Object.hashAll` is order-*dependent*, while `==` above
    // compares maps order-independently — so two equal states could hash
    // differently and both survive in a Set or as Map keys.
    var entriesHash = 0;
    for (final entry in loadingStates.entries) {
      entriesHash ^= Object.hash(entry.key, entry.value);
    }
    return Object.hash(runtimeType, entriesHash);
  }

  @override
  String toString() => 'CommonState(loadingStates: $loadingStates)';
}
