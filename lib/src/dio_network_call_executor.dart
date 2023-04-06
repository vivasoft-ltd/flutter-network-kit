import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';
import 'package:flutter_network_lib/src/dio_serializer.dart';

class DioNetworkCallExecutor {
  final NetworkErrorConverter errorConverter;
  final DioSerializer dioSerializer;
  final Dio dio;

  StreamSubscription? _connectivitySubscription;
  ConnectivityResult? _connectivityResult;
  Function(ConnectivityResult)? _onNetworkChanged;

  DioNetworkCallExecutor(
      {required this.dio,
      required this.dioSerializer,
      required this.errorConverter});

  void subscribeToConnectivityChange(
      Function(ConnectivityResult) onNetworkChanged) {
    _onNetworkChanged ??= onNetworkChanged;

    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result.isConnected() != _connectivityResult?.isConnected()) {
          _connectivityResult = result;
          if (_onNetworkChanged != null) {
            _onNetworkChanged!(result);
          }
        }
      },
    );
  }

  Future<void> unsubscribeFromConnectivityChange() async {
    await _connectivitySubscription?.cancel();
    _onNetworkChanged = null;
    _connectivitySubscription = null;
    _connectivityResult = null;
  }

  bool isNetworkConnected() {
    if (_connectivitySubscription == null) {
      throw Exception("You must subscribe to connectivity change first");
    } else {
      return _connectivityResult?.isConnected() == true;
    }
  }

  Future<Either<ErrorType, ReturnType>>
      execute<ErrorType, ReturnType, SingleItemType>(
          {required RequestOptions options}) async {
    try {
      if (options.headers[Headers.contentTypeHeader] ==
              Headers.jsonContentType &&
          options.data != null) {
        options.data = dioSerializer.convertRequest(options);
      }
      if (!options.path.startsWith('http') && options.baseUrl.isEmpty) {
        options.baseUrl = dio.options.baseUrl;
      }

      if (_connectivitySubscription != null &&
          _connectivityResult?.isConnected() != true) {
        return Left(errorConverter.convert(ConnectionError(
            type: ConnectionErrorType.noInternet,
            errorCode: 'no_internet_connection')));
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
      if (_connectivityResult?.isConnected() != true) {
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
          Map<String, dynamic>? body,
          Options? options}) async {
    try {
      if (_connectivityResult?.isConnected() != true) {
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
}

// extension on ConnectivityResult
extension ConectivityChecker on ConnectivityResult {
  bool isConnected() {
    return (this == ConnectivityResult.mobile ||
        this == ConnectivityResult.wifi);
  }
}
