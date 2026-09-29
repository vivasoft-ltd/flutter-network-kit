import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import 'helpers/mocks.dart';

void main() {
  late JsonSerializer serializer;

  Response<dynamic> response(dynamic data) =>
      Response(requestOptions: RequestOptions(), data: data);

  setUp(() {
    serializer = JsonSerializer()..addParser<Post>(Post.fromJson);
  });

  group('addParser', () {
    test('registers the parser under its type', () {
      expect(serializer.jsonParserMap.keys, [Post]);
    });
  });

  group('convertRequest', () {
    test('returns toJson() of a Serializable JSON body', () {
      final options = RequestOptions(
        data: const Post(id: 1, title: 'a'),
        headers: {Headers.contentTypeHeader: Headers.jsonContentType},
      );

      expect(serializer.convertRequest(options), {'id': 1, 'title': 'a'});
    });

    test('throws when the content type is not JSON', () {
      final options = RequestOptions(
        data: const Post(id: 1, title: 'a'),
        headers: {Headers.contentTypeHeader: Headers.formUrlEncodedContentType},
      );

      expect(() => serializer.convertRequest(options), throwsException);
    });

    test('throws when the body is not Serializable', () {
      final options = RequestOptions(
        data: {'id': 1},
        headers: {Headers.contentTypeHeader: Headers.jsonContentType},
      );

      expect(() => serializer.convertRequest(options), throwsException);
    });
  });

  group('convertResponse', () {
    test('parses a single object', () {
      final result = serializer.convertResponse<Post, Post>(
          response({'id': 1, 'title': 'a'}));

      expect(result, const Post(id: 1, title: 'a'));
    });

    test('parses a list of objects', () {
      final result = serializer.convertResponse<List<Post>, Post>(response([
        {'id': 1, 'title': 'a'},
        {'id': 2, 'title': 'b'},
      ]));

      expect(result, const [Post(id: 1, title: 'a'), Post(id: 2, title: 'b')]);
    });

    test('returns data that is already the requested type', () {
      expect(serializer.convertResponse<String, String>(response('ok')), 'ok');
      expect(
        serializer.convertResponse<List<int>, int>(response([1, 2, 3])),
        [1, 2, 3],
      );
    });
  });
}
