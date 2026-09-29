import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import 'helpers/mocks.dart';

void main() {
  late MockConnectivityPlatform connectivity;
  late StreamController<List<ConnectivityResult>> connectivityChanges;
  late MockHttpClientAdapter adapter;
  late MockNetworkErrorConverter errorConverter;
  late JsonSerializer serializer;
  late DioNetworkCallExecutor executor;

  const baseUrl = 'https://api.test';

  setUpAll(registerNetworkFallbackValues);

  void stubConnectivity(List<ConnectivityResult> results) {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => results);
  }

  void stubResponse(Object? body, {int statusCode = 200}) {
    when(() => adapter.fetch(any(), any(), any()))
        .thenAnswer((_) async => jsonResponse(body, statusCode: statusCode));
  }

  RequestOptions capturedRequest() {
    return verify(() => adapter.fetch(captureAny(), any(), any()))
        .captured
        .single as RequestOptions;
  }

  setUp(() {
    connectivity = MockConnectivityPlatform();
    connectivityChanges = StreamController.broadcast();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityChanges.stream);
    stubConnectivity([ConnectivityResult.wifi]);
    ConnectivityPlatform.instance = connectivity;

    adapter = MockHttpClientAdapter();
    stubResponse({'id': 1, 'title': 'a'});
    final dio = Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = adapter;

    errorConverter = MockNetworkErrorConverter();
    when(() => errorConverter.convert(any()))
        .thenAnswer((invocation) => invocation.positionalArguments.single);

    serializer = JsonSerializer()..addParser<Post>(Post.fromJson);
    executor = DioNetworkCallExecutor(
      dio: dio,
      dioSerializer: serializer,
      errorConverter: errorConverter,
      connectivityResult: ConnectivityResult.wifi,
    );
  });

  tearDown(() => connectivityChanges.close());

  void expectNoInternet(Either<Exception, dynamic> result) {
    expect(result.isLeft(), isTrue);
    final error = result.fold((l) => l, (r) => null);
    expect(error, isA<ConnectionError>());
    expect((error as ConnectionError).type, ConnectionErrorType.noInternet);
    expect(error.errorCode, 'no_internet_connection');
  }

  group('connectivity gate', () {
    // Regression: only wifi/mobile used to count as online, so iOS devices on
    // Ethernet, VPN or "other" interfaces were rejected as offline.
    for (final type in ConnectivityResult.values
        .where((type) => type != ConnectivityResult.none)) {
      test('sends the request when connected via ${type.name}', () async {
        stubConnectivity([type]);

        final result = await executor.get<Exception, Post, Post>('/posts/1');

        expect(result, const Right<Exception, Post>(Post(id: 1, title: 'a')));
        verify(() => adapter.fetch(any(), any(), any())).called(1);
        expect(executor.connectivityResult, type);
        expect(executor.isNetworkConnected(), isTrue);
      });
    }

    test('picks the first active type from a mixed result', () async {
      stubConnectivity([ConnectivityResult.other, ConnectivityResult.wifi]);

      await executor.get<Exception, Post, Post>('/posts/1');

      expect(executor.connectivityResult, ConnectivityResult.other);
      verify(() => adapter.fetch(any(), any(), any())).called(1);
    });

    test('returns noInternet and skips the request when offline', () async {
      stubConnectivity([ConnectivityResult.none]);

      final results = [
        await executor.execute<Exception, Post, Post>(
            options: RequestOptions(path: '/posts')),
        await executor.get<Exception, Post, Post>('/posts'),
        await executor.post<Exception, Post, Post>('/posts'),
        await executor.put<Exception, Post, Post>('/posts/1'),
        await executor.patch<Exception, Post, Post>('/posts/1'),
        await executor.delete<Exception, Post, Post>('/posts/1'),
      ];

      results.forEach(expectNoInternet);
      verifyNever(() => adapter.fetch(any(), any(), any()));
      verify(() => errorConverter.convert(any(that: isA<ConnectionError>())))
          .called(6);
      expect(executor.isNetworkConnected(), isFalse);
    });

    test('treats an empty result as offline', () async {
      stubConnectivity([]);

      expectNoInternet(await executor.get<Exception, Post, Post>('/posts'));
      verifyNever(() => adapter.fetch(any(), any(), any()));
    });
  });

  group('connectivity stream', () {
    test('subscribes and tracks changes when no initial result is given',
        () async {
      final listening = DioNetworkCallExecutor(
        dio: Dio(),
        dioSerializer: serializer,
        errorConverter: errorConverter,
      );

      expect(listening.connectivityResult, ConnectivityResult.none);
      expect(connectivityChanges.hasListener, isTrue);

      connectivityChanges.add([ConnectivityResult.ethernet]);
      await pumpEventQueue();
      expect(listening.connectivityResult, ConnectivityResult.ethernet);
      expect(listening.isNetworkConnected(), isTrue);

      connectivityChanges.add([ConnectivityResult.none]);
      await pumpEventQueue();
      expect(listening.isNetworkConnected(), isFalse);

      connectivityChanges.add([ConnectivityResult.none, ConnectivityResult.vpn]);
      await pumpEventQueue();
      expect(listening.connectivityResult, ConnectivityResult.vpn);
    });

    test('does not subscribe when an initial result is given', () {
      expect(executor.connectivityResult, ConnectivityResult.wifi);
      verifyNever(() => connectivity.onConnectivityChanged);
    });
  });

  group('HTTP methods', () {
    test('get sends query parameters and parses a list', () async {
      stubResponse([
        {'id': 1, 'title': 'a'},
        {'id': 2, 'title': 'b'},
      ]);

      final result = await executor.get<Exception, List<Post>, Post>(
        '/posts',
        queryParameters: {'page': 2},
      );

      expect(result.getOrElse(() => []), const [
        Post(id: 1, title: 'a'),
        Post(id: 2, title: 'b'),
      ]);
      final request = capturedRequest();
      expect(request.method, 'GET');
      expect(request.uri.toString(), '$baseUrl/posts?page=2');
    });

    final bodyMethods = <String,
        Future<Either<Exception, Post>> Function(
            DioNetworkCallExecutor, Map<String, dynamic>)>{
      'POST': (e, body) => e.post<Exception, Post, Post>('/posts', body: body),
      'PUT': (e, body) => e.put<Exception, Post, Post>('/posts/1', body: body),
      'PATCH': (e, body) =>
          e.patch<Exception, Post, Post>('/posts/1', body: body),
      'DELETE': (e, body) =>
          e.delete<Exception, Post, Post>('/posts/1', body: body),
    };

    bodyMethods.forEach((method, call) {
      test('${method.toLowerCase()} sends the body and parses the response',
          () async {
        stubResponse({'id': 1, 'title': 'new'});

        final result = await call(executor, {'title': 'new'});

        expect(result, const Right<Exception, Post>(Post(id: 1, title: 'new')));
        final request = capturedRequest();
        expect(request.method, method);
        expect(request.data, {'title': 'new'});
      });
    });
  });

  group('execute', () {
    test('fills in the Dio base URL and serializes a JSON body', () async {
      stubResponse({'id': 7, 'title': 'x'});

      final result = await executor.execute<Exception, Post, Post>(
        options: RequestOptions(
          path: '/posts',
          method: 'POST',
          data: const Post(id: 7, title: 'x'),
          headers: {Headers.contentTypeHeader: Headers.jsonContentType},
        ),
      );

      expect(result, const Right<Exception, Post>(Post(id: 7, title: 'x')));
      final request = capturedRequest();
      expect(request.uri.toString(), '$baseUrl/posts');
      expect(request.data, {'id': 7, 'title': 'x'});
    });

    test('leaves absolute URLs alone', () async {
      await executor.execute<Exception, Post, Post>(
        options: RequestOptions(path: 'https://other.test/posts/1'),
      );

      expect(capturedRequest().uri.toString(), 'https://other.test/posts/1');
    });
  });

  group('errors', () {
    test('passes Dio failures through the error converter', () async {
      stubResponse({'error': 'boom'}, statusCode: 500);

      final result = await executor.get<Exception, Post, Post>('/posts/1');

      final error = result.fold((l) => l, (r) => null);
      expect(error, isA<DioException>());
      expect((error as DioException).type, DioExceptionType.badResponse);
      expect(error.response?.statusCode, 500);
      verify(() => errorConverter.convert(error)).called(1);
    });

    test('passes serializer failures through the error converter', () async {
      serializer.addParser<Post>(
          (json) => throw FormatException('bad post: $json'));

      final result = await executor.get<Exception, Post, Post>('/posts/1');

      expect(result.fold((l) => l, (r) => null), isA<FormatException>());
      verify(() => errorConverter.convert(any(that: isA<FormatException>())))
          .called(1);
    });

    test('returns whatever the error converter produces', () async {
      final mapped = Exception('mapped');
      when(() => errorConverter.convert(any())).thenReturn(mapped);
      stubConnectivity([ConnectivityResult.none]);

      final result = await executor.get<Exception, Post, Post>('/posts/1');

      expect(result, Left<Exception, Post>(mapped));
    });
  });

  group('ConectivityChecker.isConnected', () {
    test('is false only for none', () {
      for (final type in ConnectivityResult.values) {
        expect(type.isConnected(), type != ConnectivityResult.none,
            reason: type.name);
      }
    });
  });
}
