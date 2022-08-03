import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_network_lib/src/dio_serializer.dart';

class DioBuiltValueSerializer implements DioSerializer{
  final Serializers serializers;

  DioBuiltValueSerializer({required this.serializers});
  @override
  dynamic convertRequest(dynamic data) {
    if (data != null) {
      data = serializers.serializeWith(
        serializers.serializerForType(data.runtimeType)!,
        data,
      );
    }
    return data;
  }

  @override
  ReturnType convertResponse<ReturnType, SingleItemType>(
    Response response,
  ) {
    final ReturnType data = _convertToCustomObject<SingleItemType>(response.data);
    return data;
  }

  dynamic _convertToCustomObject<SingleItemType>(dynamic element) {
    if (element is SingleItemType) return element;

    if (element is List) {
      return _deserializeListOf<SingleItemType>(element);
    } else {
      return _deserialize<SingleItemType>(element);
    }
  }

  BuiltList<SingleItemType> _deserializeListOf<SingleItemType>(
    List dynamicList,
  ) {
    return BuiltList<SingleItemType>(
      dynamicList.map((element) => _deserialize<SingleItemType>(element)),
    );
  }

  SingleItemType _deserialize<SingleItemType>(
    Map<String, dynamic> value,
  ) {
    return serializers.deserializeWith(
      serializers.serializerForType(SingleItemType)!,
      value,
    );
  }
}
