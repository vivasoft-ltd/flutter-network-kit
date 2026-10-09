import 'network_error_converter.dart';

/// Why a request was not sent.
enum ConnectionErrorType {
  /// The device has no active network connection.
  noInternet
}

/// Passed to [NetworkErrorConverter.convert] when a request is skipped
/// because the device is offline.
class ConnectionError implements Exception {
  /// The kind of connection problem.
  final ConnectionErrorType type;

  /// Machine-readable code, e.g. `no_internet_connection`.
  final String errorCode;

  ConnectionError({required this.type, required this.errorCode});

  @override
  String toString() => 'ConnectionError($type, $errorCode)';
}
