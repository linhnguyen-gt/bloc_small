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
  /// A map of loading states keyed by their unique identifiers.
  ///
  /// Each key represents a different loading operation in the application.
  final Map<String, bool> loadingStates;

  const CommonState({this.loadingStates = const {}});

  /// Checks if a loading operation is currently active.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the loading operation.
  ///   Defaults to [LoadingKey.global] if not specified.
  ///
  /// Returns `true` if the loading operation is active, `false` otherwise.
  bool isLoading({String? key = LoadingKey.global}) =>
      loadingStates[key] ?? false;

  /// Creates a copy of this state with the given fields replaced with new values.
  ///
  /// Parameters:
  /// - [loadingStates]: The new loading states map. If null, keeps the current value.
  ///
  /// Returns a new [CommonState] instance with updated values.
  CommonState copyWith({Map<String, bool>? loadingStates}) {
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
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(
      loadingStates.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() => 'CommonState(loadingStates: $loadingStates)';
}
