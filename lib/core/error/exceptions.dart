/// Base type for every exception this package defines.
///
/// Sealed so consumers can catch the whole family with `on AppException` and
/// switch over it exhaustively. Previously the three exception classes were
/// unrelated, so there was no way to handle "an error from bloc_small" as a
/// group.
///
/// [toString] renders [message]. Without it, the pattern this package's own
/// docs recommend — `emit(state.copyWith(error: e.toString()))` — showed
/// end users `Instance of 'NetworkException'`.
sealed class AppException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// A network request failed.
class NetworkException extends AppException {
  const NetworkException([super.message = 'A network error occurred']);
}

/// Input failed validation.
class ValidationException extends AppException {
  const ValidationException([super.message = 'A validation error occurred']);
}

/// An operation exceeded its time budget.
///
/// Named `AppTimeoutException` rather than `TimeoutException` because the
/// latter shadowed `dart:async`'s own `TimeoutException` wherever this library
/// was imported, leaving every `error is TimeoutException` branch dead for the
/// timeouts the SDK actually throws.
class AppTimeoutException extends AppException {
  const AppTimeoutException([super.message = 'A timeout error occurred']);
}
