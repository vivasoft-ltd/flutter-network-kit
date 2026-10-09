import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dio_serializer.dart';

/// Base [DioSerializer] that handles the single-item vs. list decision once.
///
/// Subclasses only describe how to build one item ([deserializeItem]) and how
/// to wrap a list of items ([wrapList]).
abstract class ItemDeserializingSerializer implements DioSerializer {
  /// Deserializes a single raw JSON value into [SingleItemType].
  @protected
  SingleItemType deserializeItem<SingleItemType>(dynamic value);

  /// Wraps deserialized [items] in the collection type this serializer returns.
  @protected
  Object wrapList<SingleItemType>(Iterable<SingleItemType> items);

  @override
  ReturnType convertResponse<ReturnType, SingleItemType>(Response response) {
    final data = response.data;
    if (data is SingleItemType) return data as ReturnType;
    if (data is List) {
      return wrapList<SingleItemType>(
        data.map(
          (item) => item is SingleItemType
              ? item
              : deserializeItem<SingleItemType>(item),
        ),
      ) as ReturnType;
    }
    return deserializeItem<SingleItemType>(data) as ReturnType;
  }
}
