import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viva_network_kit/src/dio_serializer.dart';

import '../viva_network_kit.dart';

class DioNetworkCallExecutor {
  final NetworkErrorConverter errorConverter;
  final DioSerializer dioSerializer;
  final Dio dio;
  final NetworkConnectivityChecker _connectivityChecker;

  DioNetworkCallExecutor(
      {required this.dio,
      required this.dioSerializer,
      required this.errorConverter,
      ConnectivityResult? connectivityResult})
      : _connectivityChecker =
            NetworkConnectivityChecker(initialResult: connectivityResult);

  ConnectivityResult? get connectivityResult =>
      _connectivityChecker.connectivityResult;

  bool isNetworkConnected() => _connectivityChecker.isConnected;

  /// Executes a network request using the provided [RequestOptions].
  ///
  /// This method handles checking for network connectivity, converting request
  /// data if needed, and making the actual network request using Dio. It then
  /// converts the response using the provided [DioSerializer] and returns the
  /// result wrapped in an [Either] object.
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  ///
  /// - [options]: The [RequestOptions] containing all the necessary information
  ///   to make the network request, including headers, data, method, etc.
  /// - Returns: A [Future] that completes with an [Either] containing the result or error.
  Future<Either<ErrorType, ReturnType>>
      execute<ErrorType, ReturnType, SingleItemType>({
    required RequestOptions options,
  }) {
    return _send<ErrorType, ReturnType, SingleItemType>(() {
      // **Convert Request if Needed**
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

  /// Executes a GET network request using the Dio package.
  ///
  /// This method checks for network connectivity, makes a GET request to the
  /// specified path, and then converts the response using the provided
  /// [DioSerializer]. The result is wrapped in an [Either] object, which
  /// represents either a successful response or an error.
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  /// - [path]: The path to which the GET request should be made.
  /// - [queryParameters]: Optional query parameters to include in the request.
  /// - [options]: Optional [Options] for configuring the request (e.g., headers).
  /// - Returns: A [Future] that completes with an [Either] containing the result or error.
  Future<Either<ErrorType, ReturnType>>
      get<ErrorType, ReturnType, SingleItemType>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send<ErrorType, ReturnType, SingleItemType>(
      () => dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  /// Executes a POST network request using the Dio package.
  ///
  /// This method checks for network connectivity, makes a POST request to the
  /// specified path, and then converts the response using the provided
  /// [DioSerializer]. The result is wrapped in an [Either] object, which
  /// represents either a successful response or an error.
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  /// - [path]: The path to which the POST request should be made.
  /// - [queryParameters]: Optional query parameters to include in the request.
  /// - [body]: The request body data.
  /// - [options]: Optional [Options] for configuring the request (e.g., headers).
  Future<Either<ErrorType, ReturnType>>
      post<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          dynamic body,
          Options? options}) {
    return _send<ErrorType, ReturnType, SingleItemType>(
      () => dio.post(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  Future<Either<ErrorType, ReturnType>>
      put<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? body,
          Options? options}) {
    return _send<ErrorType, ReturnType, SingleItemType>(
      () => dio.put(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Executes a DELETE network request using the Dio package.
  ///
  /// This method checks for network connectivity, makes a DELETE request to the
  /// specified path, and then converts the response using the provided
  /// [DioSerializer]. The result is wrapped in an [Either] object, which
  /// represents either a successful response or an error.
  ///
  /// - [ErrorType]: The type of error that can be returned.
  /// - [ReturnType]: The type of data that is expected in a successful response.
  /// - [SingleItemType]: The type of the single item in a list, if the response is a list.
  /// - [path]: The path to which the DELETE request should be made.
  /// - [queryParameters]: Optional query parameters to include in the request.
  /// - [body]: The request body data.
  /// - [options]: Optional [Options] for configuring the request (e.g., headers).
  /// - Returns: A [Future] that completes with an [Either] containing the result or error.
  Future<Either<ErrorType, ReturnType>>
      delete<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? body,
          Options? options}) {
    return _send<ErrorType, ReturnType, SingleItemType>(
      () => dio.delete(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  Future<Either<ErrorType, ReturnType>>
      patch<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? body,
          Options? options}) {
    return _send<ErrorType, ReturnType, SingleItemType>(
      () => dio.patch(path,
          queryParameters: queryParameters, data: body, options: options),
    );
  }

  /// Checks connectivity, runs [request] and converts its response.
  ///
  /// Returns a [ConnectionError] of type [ConnectionErrorType.noInternet]
  /// without calling [request] when the device is offline. Any exception
  /// thrown along the way is passed through [errorConverter].
  Future<Either<ErrorType, ReturnType>>
      _send<ErrorType, ReturnType, SingleItemType>(
    Future<Response> Function() request,
  ) async {
    try {
      // **Force Check Network Before Every Request**
      if (!await _connectivityChecker.checkConnection()) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response response = await request();
      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(response);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
  }
}
