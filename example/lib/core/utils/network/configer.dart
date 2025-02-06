import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import '../../../common/constants.dart';
import '../../../data/model/post.dart';
import '../exception/error_converter.dart';

class NetworkConfigurator {
  final JsonSerializer _jsonSerializer = JsonSerializer();

  NetworkConfigurator() {
    _configureParsers();
  }

  void _configureParsers() {
    _jsonSerializer.addParser<PostModel>(PostModel.fromJson);
  }

  DioNetworkCallExecutor createDioNetworkCallExecutor(
      ConnectivityResult connectivityResult) {
    return DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: Constants.BASE_URL)),
      dioSerializer: _jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter(),
      connectivityResult: connectivityResult,
    );
  }
}
