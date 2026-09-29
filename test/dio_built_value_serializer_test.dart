import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/src/dio_built_value_serializer.dart';

class User {
  final String name;
  final int age;

  const User(this.name, this.age);

  @override
  bool operator ==(Object other) =>
      other is User && other.name == name && other.age == age;

  @override
  int get hashCode => Object.hash(name, age);
}

/// Hand-written stand-in for a built_value generated serializer.
class UserSerializer implements StructuredSerializer<User> {
  @override
  final Iterable<Type> types = const [User];

  @override
  final String wireName = 'User';

  @override
  Iterable<Object?> serialize(Serializers serializers, User object,
          {FullType specifiedType = FullType.unspecified}) =>
      ['name', object.name, 'age', object.age];

  @override
  User deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final fields = <String, Object?>{};
    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      fields[key] = iterator.current;
    }
    return User(fields['name'] as String, fields['age'] as int);
  }
}

void main() {
  late DioBuiltValueSerializer serializer;

  Response<dynamic> response(dynamic data) =>
      Response(requestOptions: RequestOptions(), data: data);

  setUp(() {
    final serializers = (Serializers().toBuilder()
          ..add(UserSerializer())
          ..addPlugin(StandardJsonPlugin()))
        .build();
    serializer = DioBuiltValueSerializer(serializers: serializers);
  });

  group('convertRequest', () {
    test('serializes a built value to JSON', () {
      expect(serializer.convertRequest(const User('ann', 30)),
          {'name': 'ann', 'age': 30});
    });

    test('returns null for a null body', () {
      expect(serializer.convertRequest(null), isNull);
    });
  });

  group('convertResponse', () {
    test('deserializes a single object', () {
      final result = serializer
          .convertResponse<User, User>(response({'name': 'ann', 'age': 30}));

      expect(result, const User('ann', 30));
    });

    test('deserializes a list into a BuiltList', () {
      final result =
          serializer.convertResponse<BuiltList<User>, User>(response([
        {'name': 'ann', 'age': 30},
        {'name': 'bob', 'age': 41},
      ]));

      expect(result, BuiltList<User>(const [User('ann', 30), User('bob', 41)]));
    });

    test('returns data that is already the requested type', () {
      expect(serializer.convertResponse<String, String>(response('ok')), 'ok');
    });
  });
}
