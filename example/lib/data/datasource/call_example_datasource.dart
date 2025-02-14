import 'package:dartz/dartz.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import '../../core/di.dart';
import '../../core/utils/exception/base_error.dart';
import '../model/post.dart';

/// A data source class that demonstrates how to make network calls to retrieve
/// and create posts using the DioNetworkCallExecutor.
class CallExampleDataSource {
  /// Fetches all posts from the server.
  ///
  /// Returns an [Either] that contains either a [BaseError] or a [List] of
  /// [PostModel]s.
  Future<Either<BaseError, List<PostModel>>> getAllPosts() async {
    final response = await di<DioNetworkCallExecutor>()
        .get<BaseError, List<PostModel>, PostModel>(
      "/posts",
    );

    return response;
  }

  /// Creates a new post on the server.
  ///
  /// Takes a [PostModel] as input, which represents the post to be created.
  /// Returns an [Either] that contains either a [BaseError] or the created
  /// [PostModel].
  ///
  Future<Either<BaseError, PostModel>> createPost(PostModel post) async {
    final response = await di<DioNetworkCallExecutor>()
        .post<BaseError, PostModel, PostModel>(
      "/posts",
      body: post.toJson(),
    );

    return response;
  }
}
