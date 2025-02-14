import 'package:dartz/dartz.dart';
import 'package:example/data/datasource/call_example_datasource.dart';
import 'package:example/data/model/post.dart';
import 'package:example/domain/repository/get_call_repository.dart';

import '../../core/utils/exception/base_error.dart';

class CallExampleRepositoryImpl extends CallExampleRepository {
  final CallExampleDataSource _callExampleDataSource;

  CallExampleRepositoryImpl(this._callExampleDataSource);

  @override
  Future<Either<BaseError, List<PostModel>>> getAllPosts() {
    return _callExampleDataSource.getAllPosts();
  }

  @override
  Future<Either<BaseError, PostModel>> createPost(PostModel post) {
    return _callExampleDataSource.createPost(post);
  }
}
