import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'connection_error.dart';
import 'dio_serializer.dart';
import 'network_error_converter.dart';
import 'serialization_exception.dart';

/// Executes Dio requests behind a connectivity guard and returns the outcome
/// as an [Either]: [Left] with the converted error, or [Right] with the
/// deserialized response.
class DioNetworkCallExecutor {
  /// Last known connectivity state. Refreshed before every request and, when
  /// no initial value is supplied, on every platform connectivity change.
  ConnectivityResult? connectivityResult;

  /// Maps every failure to the caller's error type.
  final NetworkErrorConverter errorConverter;

  /// Encodes request bodies (in [execute]) and decodes every response.
  final DioSerializer dioSerializer;

  /// The configured Dio client that performs the requests.
  final Dio dio;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Creates an executor.
  ///
  /// - [connectivity]: optional [Connectivity] instance, mainly for tests.
  ///   Defaults to the platform singleton.
  /// - [connectivityResult]: optional initial state. When omitted, the
  ///   executor subscribes to connectivity changes; call [dispose] to cancel.
  DioNetworkCallExecutor({
    required this.dio,
    required this.dioSerializer,
    required this.errorConverter,
    this.connectivityResult,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    if (connectivityResult == null) {
      connectivityResult = ConnectivityResult.none;
      _subscribeToConnectivityChange();
    }
  }

  /// Subscribes to connectivity changes and keeps [connectivityResult] in sync.
  void _subscribeToConnectivityChange() {
    _connectivitySubscription ??=
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  /// Stores the first active connection in [results], or
  /// [ConnectivityResult.none] when there is none.
  void _updateConnectivity(List<ConnectivityResult> results) {
    connectivityResult = results.firstWhere(
      (result) => result.isConnected(),
      orElse: () => ConnectivityResult.none,
    );
  }

  /// Whether the last known [connectivityResult] is an active connection.
  bool isNetworkConnected() {
    return connectivityResult?.isConnected() == true;
  }

  /// Cancels the connectivity subscription. Call this when the executor is no
  /// longer needed (e.g. from a `GetIt` `dispose` callback).
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Executes a network request using the provided [RequestOptions].
  ///
  /// When the request's content type is JSON and it carries data, the data is
  /// first converted with [DioSerializer.convertRequest]. A relative [options]
  /// path without its own base URL falls back to [Dio.options.baseUrl].
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  /// - [options]: The [RequestOptions] describing the request.
  /// - Returns: A [Future] that completes with an [Either] containing the result or error.
  Future<Either<ErrorType, ReturnType>>
      execute<ErrorType, ReturnType, SingleItemType>({
    required RequestOptions options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(() {
      if (options.headers[Headers.contentTypeHeader] ==
              Headers.jsonContentType &&
          options.data != null) {
        options.data = dioSerializer.convertRequest(options);
      }

      if (!options.path.startsWith('http') && options.baseUrl.isEmpty) {
        options.baseUrl = dio.options.baseUrl;
      }

      return dio.fetch(options);
    });
  }

  /// Executes a GET request to [path].
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  /// - [queryParameters]: Optional query parameters to include in the request.
  /// - [options]: Optional [Options] for configuring the request (e.g., headers).
  /// - Returns: A [Future] that completes with an [Either] containing the result or error.
  Future<Either<ErrorType, ReturnType>>
      get<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(
      () => dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  /// Executes a POST request to [path] with an optional [body].
  ///
  /// See [get] for the meaning of the type parameters and shared arguments.
  Future<Either<ErrorType, ReturnType>>
      post<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Options? options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(
      () => dio.post(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Executes a PUT request to [path] with an optional [body].
  ///
  /// See [get] for the meaning of the type parameters and shared arguments.
  Future<Either<ErrorType, ReturnType>>
      put<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Options? options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(
      () => dio.put(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Executes a PATCH request to [path] with an optional [body].
  ///
  /// See [get] for the meaning of the type parameters and shared arguments.
  Future<Either<ErrorType, ReturnType>>
      patch<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Options? options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(
      () => dio.patch(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Executes a DELETE request to [path] with an optional [body].
  ///
  /// See [get] for the meaning of the type parameters and shared arguments.
  Future<Either<ErrorType, ReturnType>>
      delete<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Options? options,
  }) {
    return _guardedRequest<ErrorType, ReturnType, SingleItemType>(
      () => dio.delete(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Shared pipeline for every HTTP method: fresh connectivity check, the
  /// [request] itself, response deserialization, and error conversion.
  Future<Either<ErrorType, ReturnType>>
      _guardedRequest<ErrorType, ReturnType, SingleItemType>(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      // Force a fresh check: the cached value can be stale on resume.
      _updateConnectivity(await _connectivity.checkConnectivity());

      if (!isNetworkConnected()) {
        return Left(errorConverter.convert(ConnectionError(
          type: ConnectionErrorType.noInternet,
          errorCode: 'no_internet_connection',
        )));
      }

      final response = await request();
      return Right(_convertResponse<ReturnType, SingleItemType>(response));
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
  }

  /// Deserializes [response], turning non-[Exception] failures (missing
  /// parser, payload/model mismatch) into a [SerializationException] so they
  /// surface as [Left] instead of escaping the [Either].
  ReturnType _convertResponse<ReturnType, SingleItemType>(
    Response<dynamic> response,
  ) {
    try {
      return dioSerializer.convertResponse<ReturnType, SingleItemType>(
        response,
      );
    } on Exception {
      rethrow;
    } catch (error, stackTrace) {
      throw SerializationException(
        'Could not convert response from ${response.requestOptions.uri} '
        'to $ReturnType.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Extension on [ConnectivityResult] to check whether it represents an active
/// network interface (wifi, mobile, ethernet, vpn, bluetooth or other).
extension ConectivityChecker on ConnectivityResult {
  /// Returns true for every result except [ConnectivityResult.none].
  bool isConnected() => this != ConnectivityResult.none;
}
