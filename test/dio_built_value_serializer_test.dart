import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/src/dio_built_value_serializer.dart';

class Tag {
  Tag(this.name);

  final String name;
}

/// Hand-written serializer so the test doesn't need built_value codegen.
class TagSerializer implements StructuredSerializer<Tag> {
  @override
  final Iterable<Type> types = const [Tag];

  @override
  final String wireName = 'Tag';

  @override
  Iterable<Object?> serialize(Serializers serializers, Tag object,
          {FullType specifiedType = FullType.unspecified}) =>
      ['name', object.name];

  @override
  Tag deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final list = serialized.toList();
    return Tag(list[list.indexOf('name') + 1] as String);
  }
}

void main() {
  final serializer = DioBuiltValueSerializer(
    serializers: (Serializers().toBuilder()..add(TagSerializer())).build(),
  );

  Response<dynamic> response(Object? data) =>
      Response(requestOptions: RequestOptions(), data: data);

  test('convertRequest serializes the request body, not the options', () {
    final encoded = serializer.convertRequest(RequestOptions(data: Tag('a')));

    expect(encoded, ['name', 'a']);
  });

  test('convertRequest returns null when there is no body', () {
    expect(serializer.convertRequest(RequestOptions()), isNull);
  });

  test('convertResponse wraps list responses in a BuiltList', () {
    final tags = serializer.convertResponse<BuiltList<Tag>, Tag>(
      response([
        ['name', 'a'],
        ['name', 'b'],
      ]),
    );

    expect(tags, isA<BuiltList<Tag>>());
    expect(tags.map((t) => t.name), ['a', 'b']);
  });
}
