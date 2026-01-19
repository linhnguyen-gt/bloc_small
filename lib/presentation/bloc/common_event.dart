part of 'common_bloc.dart';

/// Base class for all common application-wide events.
///
/// This class serves as the foundation for events that manage
/// global application state through [CommonBloc].
///
/// All common events should extend this class to ensure proper type safety
/// and integration with the BLoC pattern.
class CommonEvent extends MainBlocEvent {
  const CommonEvent();
}

/// Event to control loading state for a specific component or operation.
///
/// This event is used to show or hide loading indicators across the application.
/// Each loading operation can be identified by a unique [key], allowing multiple
/// independent loading states to be managed simultaneously.
///
/// Example:
/// ```dart
/// // Show loading for login operation
/// commonBloc.add(SetComponentLoading(
///   key: 'login',
///   isLoading: true,
/// ));
///
/// // Hide loading after operation completes
/// commonBloc.add(SetComponentLoading(
///   key: 'login',
///   isLoading: false,
/// ));
///
/// // Use global loading state
/// commonBloc.add(SetComponentLoading(
///   key: LoadingKey.global,
///   isLoading: true,
/// ));
/// ```
///
/// See also:
/// - [CommonBloc] for handling this event
/// - [CommonState] for the resulting state
/// - [LoadingKey] for predefined loading keys
class SetComponentLoading extends CommonEvent {
  /// Unique identifier for the loading operation.
  ///
  /// This key is used to track and manage independent loading states.
  /// Use [LoadingKey.global] for application-wide loading, or provide
  /// a custom key for component-specific loading states.
  final String key;

  /// Whether the loading indicator should be shown or hidden.
  ///
  /// Set to `true` to show the loading indicator, `false` to hide it.
  final bool isLoading;

  /// Creates a [SetComponentLoading] event.
  ///
  /// Both [key] and [isLoading] are required parameters.
  ///
  /// Example:
  /// ```dart
  /// const event = SetComponentLoading(
  ///   key: 'data_fetch',
  ///   isLoading: true,
  /// );
  /// ```
  const SetComponentLoading({required this.key, required this.isLoading});
}
