import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';
import 'package:flutter_network_lib/src/dio_serializer.dart';

class DioNetworkCallExecutor {
  ConnectivityResult? connectivityResult;
  final NetworkErrorConverter errorConverter;
  final DioSerializer dioSerializer;
  final Dio dio;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  DioNetworkCallExecutor(
      {required this.dio,
      required this.dioSerializer,
      required this.errorConverter,
      this.connectivityResult}) {
    if (connectivityResult == null) {
      connectivityResult = ConnectivityResult.none;
      _subscribeToConnectivityChange();
    }
  }

  /// Subscribes to connectivity changes using the [Connectivity] package.
  ///
  /// This method listens for changes in the device's connectivity status and
  /// updates the [connectivityResult] accordingly.
  void _subscribeToConnectivityChange() {
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty &&
            results.first.isConnected() != connectivityResult?.isConnected()) {
          connectivityResult = results.first;
        }
      },
    );
  }

  bool isNetworkConnected() {
    return connectivityResult?.isConnected() == true;
  }

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
  }) async {
    try {
      // **Force Check Network Before Every Request**
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      // **Convert Request if Needed**
      if (options.headers[Headers.contentTypeHeader] ==
              Headers.jsonContentType &&
          options.data != null) {
        options.data = dioSerializer.convertRequest(options);
      }

      if (!options.path.startsWith('http') && options.baseUrl.isEmpty) {
        options.baseUrl = dio.options.baseUrl;
      }

      final Response _result = await dio.fetch(options);
      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
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
  }) async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response _result = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
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
          Options? options}) async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response _result = await dio.post(path,
          queryParameters: queryParameters, data: body, options: options);

      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
  }

  Future<Either<ErrorType, ReturnType>>
      put<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? body,
          Options? options}) async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response _result = await dio.put(path,
          queryParameters: queryParameters, data: body, options: options);

      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
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
          Options? options}) async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response _result = await dio.delete(path,
          queryParameters: queryParameters, data: body, options: options);

      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
  }

  Future<Either<ErrorType, ReturnType>>
      patch<ErrorType, ReturnType, SingleItemType>(String path,
          {Map<String, dynamic>? queryParameters,
          Map<String, dynamic>? body,
          Options? options}) async {
    try {
      List<ConnectivityResult> results =
          await Connectivity().checkConnectivity();
      connectivityResult = results.isNotEmpty
          ? results.firstWhere(
              (result) =>
                  result == ConnectivityResult.wifi ||
                  result == ConnectivityResult.mobile,
              orElse: () => ConnectivityResult.none,
            )
          : ConnectivityResult.none;

      if (connectivityResult == ConnectivityResult.none) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
      }

      final Response _result = await dio.patch(path,
          queryParameters: queryParameters, data: body, options: options);

      final result =
          dioSerializer.convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    } on Exception catch (e) {
      return Left(errorConverter.convert(e));
    }
  }
}

/// Extension on [ConnectivityResult] to easily check if the device is connected
/// to the internet via mobile or wifi.
///
/// - [isConnected]: Returns true if the device is connected to mobile or wifi.
/// otherwise it returns false.
extension ConectivityChecker on ConnectivityResult {
  bool isConnected() {
    return (this == ConnectivityResult.mobile ||
        this == ConnectivityResult.wifi);
  }
}
