import 'package:dartz/dartz.dart';

import '../../core/utils/exception/base_error.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/repository/call_example_repository.dart';
import '../datasource/call_example_datasource.dart';
import '../model/post.dart';

class CallExampleRepositoryImpl implements CallExampleRepository {
  final CallExampleDataSource _callExampleDataSource;

  CallExampleRepositoryImpl(this._callExampleDataSource);

  @override
  Future<Either<BaseError, List<PostEntity>>> getAllPosts() async {
    final result = await _callExampleDataSource.getAllPosts();
    return result.map((posts) => posts.map((p) => p.toEntity()).toList());
  }

  @override
  Future<Either<BaseError, PostEntity>> createPost(PostEntity post) async {
    final result =
        await _callExampleDataSource.createPost(PostModel.fromEntity(post));
    return result.map((created) => created.toEntity());
  }
}
