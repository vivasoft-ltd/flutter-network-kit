import 'dart:convert' as dart_convert;

import 'package:dio/dio.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

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
        case DioExceptionType.transformTimeout:
          return BaseError(
              ErrorCode.sendTimeout, "Transform timeout occurred.");
        case DioExceptionType.unknown:
          return BaseError(ErrorCode.noInternet, "No internet connection.");
        case DioExceptionType.badResponse:
          final response = exception.response;
          if (response == null) {
            return BaseError(
                ErrorCode.unexpected, "Unexpected error occurred.");
          }
          return BaseError(
            mapServerErrorCodeToApiErrorCode(response.statusCode),
            _extractMessage(response.data),
          );

        case DioExceptionType.badCertificate:
          return BaseError(ErrorCode.badCertificate, "Bad Certificate");
        case DioExceptionType.connectionError:
          return BaseError(
              ErrorCode.connectionError, "Connection error occurred");
      }
    } else if (exception is ConnectionError) {
      switch (exception.type) {
        case ConnectionErrorType.noInternet:
          return BaseError(ErrorCode.noInternet, "No internet connection.");
      }
    }
    return BaseError(ErrorCode.unexpected, "An unknown error occurred.");
  }

  /// Reads `message`/`Message` from a JSON error body (map or encoded string).
  String _extractMessage(dynamic data) {
    try {
      final body = data is String ? dart_convert.jsonDecode(data) : data;
      if (body is Map) {
        return (body["message"] ?? body["Message"])?.toString() ??
            "Unknown error occurred.";
      }
    } on FormatException {
      // Not JSON; fall through to the generic message.
    }
    return "Unknown error occurred.";
  }

  int mapServerErrorCodeToApiErrorCode(int? errorCode) {
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
