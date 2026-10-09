import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/utils/exception/base_error.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/usecase/create_post.dart';
import '../../domain/usecase/get_all_posts.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetAllPostsUseCase _getAllPosts;
  final CreatePostUseCase _createPost;

  PostBloc(this._getAllPosts, this._createPost) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<CreateNewPost>(_onCreateNewPost);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final result = await _getAllPosts();
    emit(result.fold(_toErrorState, PostLoaded.new));
  }

  Future<void> _onCreateNewPost(
    CreateNewPost event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    final result = await _createPost(event.post);
    emit(result.fold(_toErrorState, PostCreated.new));
  }

  PostState _toErrorState(BaseError failure) {
    return PostError(failure.message ?? 'An unexpected error occurred');
  }
}
