import 'dart:convert' as dart_convert;

import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import 'base_error.dart';
import 'error_code.dart';

class DioErrorToApiErrorConverter implements NetworkErrorConverter<BaseError> {
  @override
  BaseError convert(Exception exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.cancel:
          return BaseError(ErrorCode.cancel, "Request was cancelled.");
        case DioExceptionType.connectionTimeout:
          return BaseError(
              ErrorCode.connectionTimeOut, "Connection timed out.");
        case DioExceptionType.receiveTimeout:
          return BaseError(ErrorCode.sendTimeout, "Receive timeout occurred.");
        case DioExceptionType.sendTimeout:
          return BaseError(ErrorCode.sendTimeout, "Send timeout occurred.");
        case DioExceptionType.unknown:
          return BaseError(ErrorCode.noInternet, "No internet connection.");
        case DioExceptionType.badResponse:
          if (exception.response != null) {
            final responseError = exception.response?.data is String
                ? dart_convert.jsonDecode(exception.response?.data)
                : exception.response?.data;
            return _deserialize(responseError, exception.response!.statusCode!);
          } else {
            return BaseError(
                ErrorCode.unexpected, "Unexpected error occurred.");
          }
        default:
          return BaseError(ErrorCode.unexpected, "An unknown error occurred.");
      }
    } else if (exception is ConnectionError) {
      switch (exception.type) {
        case ConnectionErrorType.noInternet:
          return BaseError(ErrorCode.noInternet, "No internet connection.");
      }
    }
    return BaseError(ErrorCode.unexpected, "An unknown error occurred.");
  }

  BaseError _deserialize(Map<String, dynamic> value, int statusCode) {
    final int errorCode = statusCode;
    String errorMessage =
        value["message"] ?? value["Message"] ?? "Unknown error occurred.";

    return BaseError(
      mapServerErrorCodeToApiErrorCode(errorCode),
      errorMessage,
    );
  }

  int mapServerErrorCodeToApiErrorCode(int errorCode) {
    switch (errorCode) {
      case 400:
        return ErrorCode.defaultError;
      case 401:
        return ErrorCode.unexpected;
      case 403:
        return ErrorCode.unexpected;
      case 404:
        return ErrorCode.notFound;
      case 408:
        return ErrorCode.connectionTimeOut;
      case 500:
        return ErrorCode.unexpected;
      case 503:
        return ErrorCode.unexpected;
      case 504:
        return ErrorCode.sendTimeout;
      default:
        return ErrorCode.unexpected;
    }
  }
}
