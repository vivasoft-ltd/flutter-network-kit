import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:viva_network_call/viva_network_call.dart';
import 'dart:convert' as dart_convert;

class BaseError {
  final int? errorCode;
  final String? message;

  BaseError([this.errorCode, this.message = "message"]);
}

class ErrorCode {
  static int notFound = 101;
  static int unexpected = 102;
  static int cancel = 103;
  static int connectionTimeOut = 104;
  static int defaultError = 105;
  static int sendTimeout = 106;
}

class Post extends Serializable {
  late int userId;
  int? id;
  String? title;
  String? body;

  Post({required this.userId, this.id, this.title, this.body});

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userd'] = this.userId;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> testGetApi() async {
    JsonSerializer jsonSerializer = JsonSerializer();
    jsonSerializer.addParser<Post>(Post.fromJson);
    final dioNetworkCallExecutor = DioNetworkCallExecutor(
        dio: Dio(),
        dioSerializer: jsonSerializer,
        errorConverter: DioErrorToApiErrorConverter());

    final value =
        await dioNetworkCallExecutor.execute<BaseError, List<Post>, Post>(
            options: RequestOptions(
      headers: {
        'Content-Type': 'application/json',
      },
      method: 'GET',
      path: 'https://jsonplaceholder.typicode.com/posts',
    ));
    print(value.toString());
  }

  Future<void> testPostApi() async {
    JsonSerializer jsonSerializer = JsonSerializer();
    final dioNetworkCallExecutor = DioNetworkCallExecutor(
        dio: Dio(),
        dioSerializer: jsonSerializer,
        errorConverter: DioErrorToApiErrorConverter());

    final value = await dioNetworkCallExecutor.execute<BaseError, Map<String,dynamic>, Map<String,dynamic>>(
        options: RequestOptions(
      headers: {
        'Content-Type': 'application/json',
      },
      method: 'Post',
      data: {
        'title': 'foo',
        'body': 'bar',
        'userId': 1,
      },
      path: 'https://jsonplaceholder.typicode.com/posts',
    ));
    print(value.toString());
  }

  @override
  void initState() {
    testGetApi();
    testPostApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

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
    if (errorMessage == null || errorMessage.isEmpty) {
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
