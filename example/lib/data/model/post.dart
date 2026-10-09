import 'package:equatable/equatable.dart';

import '../../domain/entity/post_entity.dart';

/// Wire format of a post as returned by the JSONPlaceholder API.
class PostModel extends Equatable {
  const PostModel({
    required this.userId,
    this.id,
    required this.title,
    required this.body,
  });

  final num? userId;
  final int? id;
  final String? title;
  final String? body;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json["userId"],
      id: json["id"],
      title: json["title"],
      body: json["body"],
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      userId: entity.userId,
      id: entity.id,
      title: entity.title,
      body: entity.body,
    );
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
        "body": body,
      };

  PostEntity toEntity() {
    return PostEntity(
      userId: userId?.toInt() ?? 0,
      id: id,
      title: title ?? '',
      body: body ?? '',
    );
  }

  @override
  List<Object?> get props => [userId, id, title, body];
}
