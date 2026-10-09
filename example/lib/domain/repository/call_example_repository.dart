import 'package:dartz/dartz.dart';

import '../../core/utils/exception/base_error.dart';
import '../entity/post_entity.dart';

abstract class CallExampleRepository {
  Future<Either<BaseError, List<PostEntity>>> getAllPosts();
  Future<Either<BaseError, PostEntity>> createPost(PostEntity post);
}
