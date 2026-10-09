import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import '../common/constants.dart';
import '../data/datasource/call_example_datasource.dart';
import '../data/model/post.dart';
import '../data/repository/call_example_repository_impl.dart';
import '../domain/repository/call_example_repository.dart';
import '../domain/usecase/create_post.dart';
import '../domain/usecase/get_all_posts.dart';
import '../presentation/viewmodel/post_bloc.dart';
import 'utils/exception/error_converter.dart';

final GetIt di = GetIt.instance;

/// Composition root: every dependency of the app is wired here and nowhere
/// else. Classes receive their collaborators through constructors.
void setupLocator() {
  _registerNetwork();
  _registerPostFeature();
}

void _registerNetwork() {
  // Register a parser for every model the JsonSerializer must deserialize.
  di.registerSingleton(
    JsonSerializer()..addParser<PostModel>(PostModel.fromJson),
  );

  di.registerSingleton(
    Dio(
      BaseOptions(
        baseUrl: Constants.baseUrl,
        connectTimeout: const Duration(milliseconds: 3000),
        receiveTimeout: const Duration(milliseconds: 3000),
        sendTimeout: const Duration(milliseconds: 3000),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    ),
  );

  // Lazy so it is only created on first use; `dispose` cancels its
  // connectivity subscription when the container is reset.
  di.registerLazySingleton(
    () => DioNetworkCallExecutor(
      errorConverter: DioErrorToApiErrorConverter(),
      dio: di<Dio>(),
      dioSerializer: di<JsonSerializer>(),
    ),
    dispose: (executor) => executor.dispose(),
  );
}

void _registerPostFeature() {
  di
    ..registerLazySingleton(() => CallExampleDataSource(di()))
    ..registerLazySingleton<CallExampleRepository>(
      () => CallExampleRepositoryImpl(di()),
    )
    ..registerLazySingleton(() => GetAllPostsUseCase(di()))
    ..registerLazySingleton(() => CreatePostUseCase(di()))
    ..registerFactory(() => PostBloc(di(), di()));
}
