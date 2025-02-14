import 'package:dartz/dartz.dart';
import 'package:example/domain/repository/get_call_repository.dart';

import '../../core/utils/exception/base_error.dart';
import '../../data/model/post.dart';

class CreatePost {
  final CallExampleRepository _callExampleRepository;

  CreatePost(this._callExampleRepository);

  Future<Either<BaseError, PostModel>> call(PostModel post) {
    return _callExampleRepository.createPost(post);
  }
}
