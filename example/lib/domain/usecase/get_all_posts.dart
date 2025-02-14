import 'package:dartz/dartz.dart';
import 'package:example/domain/repository/get_call_repository.dart';

import '../../core/utils/exception/base_error.dart';
import '../../data/model/post.dart';

class GetAllPosts {
  final CallExampleRepository _callExampleRepository;

  GetAllPosts(this._callExampleRepository);

  Future<Either<BaseError, List<PostModel>>> get() {
    return _callExampleRepository.getAllPosts();
  }
}
