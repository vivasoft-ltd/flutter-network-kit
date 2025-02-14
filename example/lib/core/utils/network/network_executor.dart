import 'package:dio/dio.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import '../../../common/constants.dart';
import '../../../data/model/post.dart';
import '../exception/error_converter.dart';

class NetworkExecutor {
  final JsonSerializer _jsonSerializer = JsonSerializer();

  NetworkExecutor() {
    _configureParsers();
  }

  void _configureParsers() {
    _jsonSerializer.addParser<PostModel>(PostModel.fromJson);
  }

  static DioNetworkCallExecutor setup() {
    final networkExecutor = NetworkExecutor();
    return networkExecutor
        ._createDioNetworkCallExecutor(ConnectivityResult.none);
  }

  DioNetworkCallExecutor _createDioNetworkCallExecutor(
      ConnectivityResult connectivityResult) {
    return DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: Constants.BASE_URL)),
      dioSerializer: _jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter(),
      connectivityResult: connectivityResult,
    );
  }
}
