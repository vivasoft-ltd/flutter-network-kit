enum ConnectionErrorType { noInternet }

class ConnectionError implements Exception {
  final ConnectionErrorType type;
  final String errorCode;

  ConnectionError({required this.type, required this.errorCode});
}
