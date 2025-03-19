import 'package:equatable/equatable.dart';

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

  PostModel copyWith({
    num? userId,
    int? id,
    String? title,
    String? body,
  }) {
    return PostModel(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json["userId"],
      id: json["id"],
      title: json["title"],
      body: json["body"],
    );
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
        "body": body,
      };

  @override
  String toString() {
    return "$userId, $id, $title, $body, ";
  }

  @override
  List<Object?> get props => [
        userId,
        id,
        title,
        body,
      ];
}
