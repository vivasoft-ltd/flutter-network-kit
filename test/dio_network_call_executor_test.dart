import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeConnectivity connectivity;
  late FakeAdapter adapter;
  late DioNetworkCallExecutor executor;

  setUp(() {
    connectivity = FakeConnectivity();
    adapter = FakeAdapter(body: {'id': 1});
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    executor = DioNetworkCallExecutor(
      dio: dio,
      dioSerializer: JsonSerializer()..addParser<Item>(Item.fromJson),
      errorConverter: PassThroughErrorConverter(),
      connectivity: connectivity,
    );
  });

  tearDown(() => executor.dispose());

  Future<Either<Exception, Item>> callMethod(String method) {
    switch (method) {
      case 'GET':
        return executor.get<Exception, Item, Item>('/items');
      case 'POST':
        return executor.post<Exception, Item, Item>('/items', body: {'id': 1});
      case 'PUT':
        return executor.put<Exception, Item, Item>('/items', body: {'id': 1});
      case 'PATCH':
        return executor.patch<Exception, Item, Item>('/items', body: {'id': 1});
      case 'DELETE':
        return executor.delete<Exception, Item, Item>('/items');
    }
    throw ArgumentError(method);
  }

  for (final method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) {
    group(method, () {
      test('returns Right with the parsed model when online', () async {
        final result = await callMethod(method);

        expect(result.getOrElse(() => throw 'unexpected Left').id, 1);
        expect(adapter.lastRequest?.method, method);
      });

      test('returns Left(ConnectionError) and skips the call when offline',
          () async {
        connectivity.results = [ConnectivityResult.none];

        final result = await callMethod(method);

        final error = result.swap().getOrElse(() => throw 'unexpected Right');
        expect(error, isA<ConnectionError>());
        expect((error as ConnectionError).type, ConnectionErrorType.noInternet);
        expect(adapter.requestCount, 0);
      });
    });
  }

  test('treats ethernet and vpn connections as online', () async {
    for (final result in [
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn
    ]) {
      connectivity.results = [result];

      final response = await executor.get<Exception, Item, Item>('/items');

      expect(response.isRight(), isTrue, reason: '$result should be online');
    }
  });

  test('converts Dio errors into Left via the error converter', () async {
    adapter.statusCode = 500;

    final result = await executor.get<Exception, Item, Item>('/items');

    final error = result.swap().getOrElse(() => throw 'unexpected Right');
    expect(error, isA<DioException>());
    expect((error as DioException).type, DioExceptionType.badResponse);
  });

  test('returns Left(SerializationException) when no parser is registered',
      () async {
    final result = await executor.get<Exception, String, Uri>('/items');

    final error = result.swap().getOrElse(() => throw 'unexpected Right');
    expect(error, isA<SerializationException>());
    expect((error as SerializationException).cause, isA<StateError>());
  });

  test('returns Left(SerializationException) when the payload shape mismatches',
      () async {
    adapter.body = {
      'data': [
        {'id': 1}
      ]
    };

    final result = await executor.get<Exception, List<Item>, Item>('/items');

    expect(
      result.swap().getOrElse(() => throw 'unexpected Right'),
      isA<SerializationException>(),
    );
  });

  test('execute serializes the body and applies the Dio base URL', () async {
    final result = await executor.execute<Exception, Item, Item>(
      options: RequestOptions(
        path: '/items',
        method: 'POST',
        data: Item(7),
        headers: {Headers.contentTypeHeader: Headers.jsonContentType},
      ),
    );

    expect(result.isRight(), isTrue);
    expect(adapter.lastRequest?.baseUrl, 'https://api.test');
    expect(adapter.lastRequest?.data, {'id': 7});
  });

  test('keeps connectivityResult in sync with the change stream', () async {
    connectivity.controller.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);
    expect(executor.isNetworkConnected(), isTrue);

    connectivity.controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    expect(executor.isNetworkConnected(), isFalse);
  });

  test('dispose stops listening to connectivity changes', () async {
    await executor.dispose();

    expect(connectivity.controller.hasListener, isFalse);
  });
}
