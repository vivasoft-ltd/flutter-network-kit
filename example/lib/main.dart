import 'package:dio/dio.dart';
import 'package:example/json_serializable/base_error.dart';
import 'package:example/json_serializable/error_coverter.dart';
import 'package:example/json_serializable/model/post.dart';
import 'package:flutter/material.dart';

import 'dart:convert' as dart_convert;

import 'package:flutter_network_lib/flutter_network_lib.dart';

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
  debugPrint(value.toString());
}

Future<void> testPostApi() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(),
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
    path: 'https://jsonplaceholder.typicode.com/posts',
  ));
  print(value.toString());
}

Future<void> jsonSerializableWay() async {
  testGetApi();
  testPostApi();
}

void main() async {
  await jsonSerializableWay();
}
