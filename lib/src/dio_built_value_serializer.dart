import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'item_deserializing_serializer.dart';

/// [DioSerializer] for `built_value` models. List responses are returned as
/// [BuiltList].
class DioBuiltValueSerializer extends ItemDeserializingSerializer {
  final Serializers serializers;

  DioBuiltValueSerializer({required this.serializers});

  @override
  dynamic convertRequest(RequestOptions options) {
    final data = options.data;
    if (data == null) return null;
    return serializers.serializeWith(
      _serializerFor(data.runtimeType),
      data,
    );
  }

  @override
  SingleItemType deserializeItem<SingleItemType>(dynamic value) {
    return serializers.deserializeWith(
      _serializerFor(SingleItemType),
      value,
    ) as SingleItemType;
  }

  @override
  BuiltList<SingleItemType> wrapList<SingleItemType>(
    Iterable<SingleItemType> items,
  ) =>
      BuiltList<SingleItemType>(items);

  Serializer<Object?> _serializerFor(Type type) {
    final serializer = serializers.serializerForType(type);
    if (serializer == null) {
      throw StateError('No built_value serializer registered for $type.');
    }
    return serializer;
  }
}
