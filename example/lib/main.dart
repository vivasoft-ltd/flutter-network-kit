import 'package:dio/dio.dart';
import 'package:example/json_serializable/base_error.dart';
import 'package:example/json_serializable/error_converter.dart';
import 'package:example/json_serializable/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

Future<void> testGetApi() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  jsonSerializer.addParser<Post>(Post.fromJson);
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value =
      await dioNetworkCallExecutor.execute<BaseError, List<Post>, Post>(
          options: RequestOptions(
            headers: {
      'Content-Type': 'application/json',
    },
    method: 'GET',
    path: '/posts',
  ));
  debugPrint(value.toString());
}

Future<void> testPostApi() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value = await dioNetworkCallExecutor
      .execute<BaseError, Map<String, dynamic>, Map<String, dynamic>>(
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
    path: '/posts',
  ));
  print(value.toString());
}

Future<void> testPostApi2() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value = await dioNetworkCallExecutor.post<BaseError, String, String>(
    'https://viva.pihr.xyz/token',
    options: Options(
      headers: {'Content-type': 'application/x-www-form-urlencoded'},
    ),
    body: {
      'username': 'fuad',
      'password': 'p1hr#aPk_pAs5',
      'grant_type': 'password',
      'companyId': '2',
      'deviceId': '',
      'deviceToken': ''
    },
  );
  print(value.toString());
}

Future<void> jsonSerializableWay() async {
  testGetApi();
  //testPostApi();
  // testPostApi2();
}

void main() async {
  await jsonSerializableWay();
}
