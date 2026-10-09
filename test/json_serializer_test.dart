import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import 'helpers/fakes.dart';

Response<dynamic> _response(Object? data) =>
    Response(requestOptions: RequestOptions(), data: data);

void main() {
  late JsonSerializer serializer;

  setUp(() {
    serializer = JsonSerializer()..addParser<Item>(Item.fromJson);
  });

  group('convertResponse', () {
    test('parses a single object with the registered parser', () {
      final item = serializer.convertResponse<Item, Item>(_response({'id': 1}));

      expect(item.id, 1);
    });

    test('parses a list into List<SingleItemType>', () {
      final items = serializer.convertResponse<List<Item>, Item>(
        _response([
          {'id': 1},
          {'id': 2},
        ]),
      );

      expect(items.map((e) => e.id), [1, 2]);
    });

    test('returns data unchanged when it already has the requested type', () {
      final text = serializer.convertResponse<String, String>(_response('ok'));

      expect(text, 'ok');
    });

    test('throws a descriptive StateError when no parser is registered', () {
      expect(
        () =>
            JsonSerializer().convertResponse<Item, Item>(_response({'id': 1})),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('addParser<Item>'),
        )),
      );
    });
  });

  group('convertRequest', () {
    test('serializes a Serializable body', () {
      final json = serializer.convertRequest(RequestOptions(data: Item(3)));

      expect(json, {'id': 3});
    });

    test('serializes a list of Serializable items', () {
      final json = serializer.convertRequest(
        RequestOptions(data: [Item(1), Item(2)]),
      );

      expect(json, [
        {'id': 1},
        {'id': 2},
      ]);
    });

    test('passes an already-encoded map through unchanged', () {
      final json = serializer.convertRequest(RequestOptions(data: {'id': 4}));

      expect(json, {'id': 4});
    });
  });
}
