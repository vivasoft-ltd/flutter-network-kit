import 'package:dio/dio.dart';

import 'item_deserializing_serializer.dart';

/// Implemented by request models that [JsonSerializer] can encode.
abstract class Serializable {
  /// Returns the JSON representation of this object.
  Map<String, dynamic> toJson();
}

/// Builds a [T] from a decoded JSON object, e.g. `MyModel.fromJson`.
typedef JsonParser<T> = T Function(Map<String, dynamic>);

/// Registry-based JSON serializer.
///
/// Register a parser for every model at startup with [addParser]; responses
/// are then converted to that model (or a `List` of it) automatically.
class JsonSerializer extends ItemDeserializingSerializer {
  /// Registered parsers, keyed by model type. Prefer [addParser].
  Map<Type, JsonParser<dynamic>> jsonParserMap = {};

  /// Registers [jsonParser] for [SingleItemType], for both single-object and
  /// list responses.
  void addParser<SingleItemType>(JsonParser<SingleItemType> jsonParser) {
    jsonParserMap[SingleItemType] = jsonParser;
  }

  /// Converts [Serializable] request data (or a list of it) to JSON. Any other
  /// data, such as an already-encoded `Map`, is passed through unchanged.
  @override
  dynamic convertRequest(RequestOptions options) {
    final data = options.data;
    if (data is Serializable) return data.toJson();
    if (data is List) {
      return data
          .map((item) => item is Serializable ? item.toJson() : item)
          .toList();
    }
    return data;
  }

  @override
  SingleItemType deserializeItem<SingleItemType>(dynamic value) {
    final parser = jsonParserMap[SingleItemType];
    if (parser == null) {
      throw StateError(
        'No JSON parser registered for $SingleItemType. '
        'Call addParser<$SingleItemType>(...) before making requests.',
      );
    }
    return parser(value) as SingleItemType;
  }

  @override
  List<SingleItemType> wrapList<SingleItemType>(
    Iterable<SingleItemType> items,
  ) =>
      items.toList();
}
