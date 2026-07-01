import 'package:dio/dio.dart';

import 'dio_serializer.dart';

abstract class Serializable {
  Map<String, dynamic> toJson();
}

typedef JsonParser<T> = T Function(Map<String, dynamic>);

class JsonSerializer implements DioSerializer {
  Map<Type, JsonParser> jsonParserMap = {};

  addParser<SingleItemType>(JsonParser<SingleItemType> jsonParser) {
    jsonParserMap[SingleItemType] = jsonParser;
  }

  @override
  dynamic convertRequest(RequestOptions options) {
    if (options.headers[Headers.contentTypeHeader] != Headers.jsonContentType) {
      throw Exception("");
    }
    if (options.data is! Serializable) {
      throw Exception();
    }
    return options.data.toJson();
  }

  @override
  ReturnType convertResponse<ReturnType, SingleItemType>(Response response) {
    return _convertToCustomObject<SingleItemType>(response.data);
  }

  dynamic _convertToCustomObject<SingleItemType>(dynamic element) {
    if (element is SingleItemType) return element;

    if (element is List) {
      return _deserializeListOf<SingleItemType>(element);
    } else {
      return _deserialize<SingleItemType>(element);
    }
  }

  List<SingleItemType> _deserializeListOf<SingleItemType>(
    List dynamicList,
  ) {
    return dynamicList
        .map((element) => _deserialize<SingleItemType>(element))
        .toList();
  }

  SingleItemType _deserialize<SingleItemType>(dynamic singleItem) {
    if (singleItem is SingleItemType) return singleItem;
    return jsonParserMap[SingleItemType]!(singleItem);
  }
}
