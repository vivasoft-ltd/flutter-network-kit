import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';
import 'package:flutter_network_lib/src/dio_serializer.dart';


class DioNetworkCallExecutor {
  final NetworkErrorConverter errorConverter;
  final DioSerializer dioSerializer;
  final Dio dio;
  DioNetworkCallExecutor({required this.dio, required this.dioSerializer, required this.errorConverter});
  Future<Either<ErrorType, ReturnType>>
      execute<ErrorType,ReturnType, SingleItemType>({
    required RequestOptions options
  }) async {
    try {
      if (options.headers[Headers.contentTypeHeader] ==
              Headers.jsonContentType && options.data != null) {
        options.data = dioSerializer.convertRequest(options);
      }
      final Response _result = await dio.fetch(options);

      final result = dioSerializer
          .convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    }
    on Exception catch (e){
      return Left(errorConverter.convert(e));
    }
  }

  Future<Either<ErrorType, ReturnType>>
  get<ErrorType,ReturnType, SingleItemType>(String path,{
    Map<String, dynamic>? queryParameters,
  }) async {
    try {

      final Response _result = await dio.get(path, queryParameters: queryParameters);

      final result = dioSerializer
          .convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    }
    on Exception catch (e){
      return Left(errorConverter.convert(e));
    }
  }

  Future<Either<ErrorType, ReturnType>>
  post<ErrorType,ReturnType, SingleItemType>(String path,{
    Map<String, dynamic>? body,
  }) async {
    try {

      final Response _result = await dio.post(path, data: jsonEncode(body));

      final result = dioSerializer
          .convertResponse<ReturnType, SingleItemType>(_result);
      return Right(result);
    }
    on Exception catch (e){
      return Left(errorConverter.convert(e));
    }
  }


}
