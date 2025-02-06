part of 'post_bloc.dart';

sealed class PostEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPosts extends PostEvent {}

class CreateNewPost extends PostEvent {
  final PostModel post;

  CreateNewPost(this.post);

  @override
  List<Object?> get props => [post];
}
