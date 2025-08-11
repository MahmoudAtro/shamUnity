import 'package:shamunity/models/post.dart';

class Comment {
  final int id;
  final String content;
  final String createdAt;
  final Author author;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      author: Author.fromJson(json['author']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt,
      'author': author.toJson(),
    };
  }
}
