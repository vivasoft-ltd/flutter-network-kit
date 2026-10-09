import 'package:equatable/equatable.dart';

/// Domain representation of a post, independent of any transport format.
class PostEntity extends Equatable {
  const PostEntity({
    required this.userId,
    this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int? id;
  final String title;
  final String body;

  @override
  List<Object?> get props => [userId, id, title, body];
}
