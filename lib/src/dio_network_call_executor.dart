import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viva_network_call/src/dio_serializer.dart';
import 'package:viva_network_call/src/network_error_converter.dart';


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
}
