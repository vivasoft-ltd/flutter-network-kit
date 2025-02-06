import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:example/data/model/post.dart';
import 'package:example/domain/usecase/get_all_posts.dart';

import '../../core/utils/exception/base_error.dart';
import '../../domain/usecase/post_request.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetAllPosts _getAllPosts;
  final CreatePost _createPost;

  PostBloc(this._getAllPosts, this._createPost) : super(PostInitial()) {
    on<FetchPosts>((event, emit) async {
      emit(PostLoading());

      final Either<BaseError, List<PostModel>> result =
          await _getAllPosts.get();

      result.fold(
        (error) => emit(PostError(_mapFailureToMessage(error))),
        (posts) => emit(PostLoaded(posts)),
      );
    });

    on<CreateNewPost>((event, emit) async {
      emit(PostLoading());

      final Either<BaseError, PostModel> result =
          await _createPost.call(event.post);

      result.fold((error) => emit(PostError(_mapFailureToMessage(error))),
          (post) {
        emit(PostCreated(post));
        log(post.toString());
      });
    });
  }
}

String _mapFailureToMessage(BaseError failure) {
  return failure.message ?? 'An unexpected error occurred';
}
