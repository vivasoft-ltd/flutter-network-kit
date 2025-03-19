import 'package:dio/dio.dart';
import 'package:example/common/constants.dart';
import 'package:example/core/utils/exception/error_converter.dart';
import 'package:get_it/get_it.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import '../data/model/post.dart';

final GetIt di = GetIt.instance;

/// This function initializes the dependency injection container.
/// It registers various singletons and lazy singletons
/// required for the application to function correctly.
void setupLocator() {
  // Register a singleton instance of JsonSerializer.
  // JsonSerializer is used to serialize and deserialize JSON data.
  di.registerSingleton(JsonSerializer());

  // Register a singleton instance of Dio.
  // Dio is an HTTP client used for making network requests.
  di.registerSingleton(
    Dio(
      BaseOptions(
        baseUrl: Constants.BASE_URL,
        connectTimeout: const Duration(milliseconds: 3000),
        receiveTimeout: const Duration(milliseconds: 3000),
        sendTimeout: const Duration(milliseconds: 3000),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    ),
  );

  di.registerLazySingleton(
    // Register a lazy singleton instance of DioNetworkCallExecutor.
    // DioNetworkCallExecutor is responsible for executing network calls using Dio.
    // It also handles error conversion and serialization.
    // It is registered as lazy singleton to be created only when needed.
    () => DioNetworkCallExecutor(
        errorConverter: DioErrorToApiErrorConverter(),
        dio: di<Dio>(),
        dioSerializer: di<JsonSerializer>(),
        connectivityResult: ConnectivityResult.none),
  );

  // Register a parser for PostModel.
  // This enables the JsonSerializer to properly deserialize JSON into PostModel objects.
  di<JsonSerializer>().addParser<PostModel>(PostModel.fromJson);
}
