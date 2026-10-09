import 'package:dartz/dartz.dart';

import '../../core/utils/exception/base_error.dart';
import '../entity/post_entity.dart';
import '../repository/call_example_repository.dart';

class GetAllPostsUseCase {
  final CallExampleRepository _callExampleRepository;

  GetAllPostsUseCase(this._callExampleRepository);

  Future<Either<BaseError, List<PostEntity>>> call() {
    return _callExampleRepository.getAllPosts();
  }
}
