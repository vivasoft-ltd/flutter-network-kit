import 'connection_error.dart';
import 'dio_network_call_executor.dart';
import 'serialization_exception.dart';

/// Maps every failure from [DioNetworkCallExecutor] to your app's error type
/// [T].
///
/// [convert] receives a [ConnectionError] when offline, a `DioException` when
/// the request fails, or a [SerializationException] when the response can't
/// be parsed.
abstract class NetworkErrorConverter<T> {
  /// Converts [exception] into an error of type [T].
  T convert(Exception exception);
}
