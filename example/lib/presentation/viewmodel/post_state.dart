part of 'post_bloc.dart';

sealed class PostState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;

  PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class PostCreated extends PostState {
  final PostModel post;

  PostCreated(this.post);

  @override
  List<Object?> get props => [post];
}

class PostError extends PostState {
  final String message;

  PostError(this.message);

  @override
  List<Object?> get props => [message];
}
