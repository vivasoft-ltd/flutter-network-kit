import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:example/core/utils/network/network_executor.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import '../../core/utils/exception/base_error.dart';
import '../model/post.dart';

class CallExampleDataSource {
  final INetworkExecutor _networkExecutor;

  CallExampleDataSource(this._networkExecutor);

  Future<Either<BaseError, List<PostModel>>> getAllPosts() async {
    final response = await _networkExecutor
        .getExecutor(ConnectivityResult.none)
        .get<BaseError, List<PostModel>, PostModel>(
          "/posts",
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

    return response;
  }

  Future<Either<BaseError, PostModel>> createPost(PostModel post) async {
    final response = await _networkExecutor
        .getExecutor(ConnectivityResult.none)
        .post<BaseError, PostModel, PostModel>(
          "/posts",
          body: post.toJson(),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

    return response;
  }
}
