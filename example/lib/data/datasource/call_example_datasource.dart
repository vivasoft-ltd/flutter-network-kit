import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:example/core/utils/network/network_executor.dart';

import '../../core/utils/exception/base_error.dart';
import '../model/post.dart';

class CallExampleDataSource {
  final _networkCallExecutor = NetworkExecutor.setup();

  /// Fetches all posts from the server.
  ///
  /// This method sends a GET request to the "/posts" endpoint.
  /// It expects a list of [PostModel] in the response body.
  ///
  /// Returns an [Either] that contains a [List<PostModel>] on success, or a [BaseError] on failure.
  Future<Either<BaseError, List<PostModel>>> getAllPosts() async {
    final response =
        await _networkCallExecutor.get<BaseError, List<PostModel>, PostModel>(
      "/posts",
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    return response;
  }

  /// Creates a new post on the server.
  ///
  /// This method sends a POST request to the "/posts" endpoint.
  /// It serializes the given [post] to JSON and includes it in the request body.
  ///
  /// The response is expected to be a single [PostModel] representing the
  /// newly created post.
  ///
  /// Returns an [Either] that contains the created [PostModel] on success,
  /// or a [BaseError] on failure.
  Future<Either<BaseError, PostModel>> createPost(PostModel post) async {
    final response =
        await _networkCallExecutor.post<BaseError, PostModel, PostModel>(
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
