import 'package:dartz/dartz.dart';

import '../../core/utils/exception/base_error.dart';
import '../entity/post_entity.dart';
import '../repository/call_example_repository.dart';

class CreatePostUseCase {
  final CallExampleRepository _callExampleRepository;

  CreatePostUseCase(this._callExampleRepository);

  Future<Either<BaseError, PostEntity>> call(PostEntity post) {
    return _callExampleRepository.createPost(post);
  }
}
