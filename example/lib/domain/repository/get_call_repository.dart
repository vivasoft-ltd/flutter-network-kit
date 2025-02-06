import 'package:dartz/dartz.dart';

import '../../core/utils/exception/base_error.dart';
import '../../data/model/post.dart';

abstract class CallExampleRepository {
  Future<Either<BaseError, List<PostModel>>> getAllPosts();
  Future<Either<BaseError, PostModel>> createPost(PostModel post);
}
