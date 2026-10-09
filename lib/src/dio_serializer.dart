import 'package:dio/dio.dart';

import 'dio_simple_serializer.dart';

/// Converts request bodies to the wire format and responses to typed models.
///
/// See [JsonSerializer] for the default implementation.
abstract class DioSerializer {
  /// Returns the encoded body for [options]' `data`.
  dynamic convertRequest(RequestOptions options);

  /// Converts [response]'s data to [ReturnType]. For list responses
  /// [SingleItemType] is the element type; otherwise it equals [ReturnType].
  ReturnType convertResponse<ReturnType, SingleItemType>(Response response);
}
