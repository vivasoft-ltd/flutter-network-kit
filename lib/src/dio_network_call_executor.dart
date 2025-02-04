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

extension ConectivityChecker on ConnectivityResult {
  bool isConnected() {
    return (this == ConnectivityResult.mobile ||
        this == ConnectivityResult.wifi);
  }
}
