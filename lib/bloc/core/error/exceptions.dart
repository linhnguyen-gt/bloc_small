class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'A network error occurred']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'A validation error occurred']);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'A timeout error occurred']);
}
