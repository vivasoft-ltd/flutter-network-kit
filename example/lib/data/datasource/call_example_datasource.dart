import 'package:dartz/dartz.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import '../../core/utils/exception/base_error.dart';
import '../model/post.dart';

/// A data source class that demonstrates how to make network calls to retrieve
/// and create posts using the [DioNetworkCallExecutor].
class CallExampleDataSource {
  final DioNetworkCallExecutor _executor;

  CallExampleDataSource(this._executor);

  /// Fetches all posts from the server.
  Future<Either<BaseError, List<PostModel>>> getAllPosts() {
    return _executor.get<BaseError, List<PostModel>, PostModel>("/posts");
  }

  /// Creates a new post on the server and returns the created post.
  Future<Either<BaseError, PostModel>> createPost(PostModel post) {
    return _executor.post<BaseError, PostModel, PostModel>(
      "/posts",
      body: post.toJson(),
    );
  }
}
