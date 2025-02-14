import 'package:dio/dio.dart';
import 'package:example/common/constants.dart';
import 'package:example/core/utils/exception/error_converter.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';
import 'package:get_it/get_it.dart';

import '../data/model/post.dart';

final GetIt di = GetIt.instance;

void setupLocator() {
  di.registerSingleton(JsonSerializer());

  di.registerLazySingleton(
    () => DioNetworkCallExecutor(
        errorConverter: DioErrorToApiErrorConverter(),
        dio: di<Dio>(),
        dioSerializer: di<JsonSerializer>(),
        connectivityResult: ConnectivityResult.none),
  );

  di.registerSingleton(
    Dio(
      BaseOptions(
        baseUrl: Constants.BASE_URL,
        connectTimeout: Duration(milliseconds: 3000),
        receiveTimeout: Duration(milliseconds: 3000),
        sendTimeout: Duration(milliseconds: 3000),
      ),
    ),
  );

  di<JsonSerializer>().addParser<PostModel>(PostModel.fromJson);
}
