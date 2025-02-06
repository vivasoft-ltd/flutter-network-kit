import 'package:dartz/dartz.dart';
import 'package:example/domain/repository/get_call_repository.dart';

import '../../core/utils/exception/base_error.dart';
import '../../data/model/post.dart';

class CreatePost {
  final CallExampleRepository _callExampleRepository;

  CreatePost(this._callExampleRepository);

  Future<Either<BaseError, PostModel>> call(PostModel post) async {
    final result = await _callExampleRepository.createPost(post);
    return result.fold((err) => Left(err), (data) => Right(data));
  }
}
