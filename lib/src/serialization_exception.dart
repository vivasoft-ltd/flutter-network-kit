/// Thrown (and passed to `NetworkErrorConverter.convert`) when a response
/// cannot be deserialized into the requested type, e.g. no parser is
/// registered or the payload shape doesn't match the model.
class SerializationException implements Exception {
  final String message;

  /// The original error raised during deserialization, if any.
  final Object? cause;
  final StackTrace? stackTrace;

  SerializationException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'SerializationException: $message'
      '${cause == null ? '' : ' (cause: $cause)'}';
}
