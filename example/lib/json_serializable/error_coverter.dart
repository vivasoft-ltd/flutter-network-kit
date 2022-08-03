
import 'dart:convert' as dart_convert;
import 'package:dio/dio.dart';
import 'package:example/json_serializable/base_error.dart';
import 'package:example/json_serializable/error_code.dart';
import 'package:viva_network_call/viva_network_call.dart';

class DioErrorToApiErrorConverter implements NetworkErrorConverter<BaseError> {
  @override
  BaseError convert(Exception exception) {
    if (exception is DioError) {
      switch (exception.type) {
        case DioErrorType.cancel:
          return BaseError(ErrorCode.cancel);
        case DioErrorType.connectTimeout:
          return BaseError(ErrorCode.connectionTimeOut);
        case DioErrorType.other:
          return BaseError(
              ErrorCode.connectionTimeOut, "no internet connection");
        case DioErrorType.receiveTimeout:
          return BaseError(ErrorCode.defaultError);
        case DioErrorType.response:
          if (exception.response != null) {
            final responseError = exception.response?.data is String
                ? dart_convert.jsonDecode(exception.response?.data)
                : exception.response?.data;
            if (responseError is List) {
              return _desirialize(
                  responseError.first, exception.response!.statusCode!);
            } else {
              return _desirialize(
                  responseError, exception.response!.statusCode!);
            }
          } else {
            return BaseError(ErrorCode.unexpected);
          }
        case DioErrorType.sendTimeout:
          return BaseError(ErrorCode.sendTimeout);

        default:
          return BaseError(ErrorCode.unexpected);
      }
    } else {
      return BaseError(ErrorCode.unexpected);
    }
  }

  BaseError _desirialize(Map<String, dynamic> value, int statusCode) {
    final errorCode = statusCode;
    //final errorCode = value["statusCode"] as int;
    String errorMessage = value["Message"] as String;
    if (errorMessage.isEmpty) {
      errorMessage = value["message"] as String;
    }
    return BaseError(
      mapServerErrorCodeToApiErrorCode(errorCode),
      errorMessage,
    );
  }

  int mapServerErrorCodeToApiErrorCode(int errorCode) {
    switch (errorCode) {
      case 101:
        return ErrorCode.notFound;
      case 404:
        return ErrorCode.notFound;
      default:
        return ErrorCode.unexpected;
    }
  }
}