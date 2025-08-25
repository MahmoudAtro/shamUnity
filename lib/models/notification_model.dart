import 'package:shamunity/models/post.dart';

class NotificationModel {
  final String id;
  final String message;
  final String? readAt;
  final String createdAt;
  final int? payloadType;
  final NotificationPayload? payload;

  NotificationModel({
    required this.id,
    required this.message,
    this.readAt,
    required this.createdAt,
    this.payloadType,
    this.payload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'],
      readAt: json['read_at'],
      createdAt: json['created_at'],
      payloadType: json['payload_type'] as int?,
      payload: json['payload'] != null
          ? NotificationPayload.fromJson(json['payload'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'read_at': readAt,
      'created_at': createdAt,
      'payload_type': payloadType,
      'payload': payload?.toJson(),
    };
  }

  bool get isRead => readAt != null;

  NotificationModel copyWith({
    String? id,
    String? message,
    String? readAt,
    String? createdAt,
    int? payloadType,
    NotificationPayload? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      payloadType: payloadType ?? this.payloadType,
      payload: payload ?? this.payload,
    );
  }
}

class NotificationPayload {
  final Post? post;
  final Author? author;

  NotificationPayload({
    this.post,
    this.author,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      post: Post(
        id: json['id'],
        content: json['content'],
        createdAt: json['created_at'],
        likesCount: json['likes_count'],
        commentsCount: json['comments_count'],
        isLiked: json['is_liked_by_user'],
        author: Author(
          id: json['author']['id'],
          name: json['author']['name'],
          email: json['author']['email'],
          profilePictureUrl: json['author']['profile_picture'],
          gender: json['author']['gender'],
          birthDate: json['author']['birth_date'],
          universityId: json['author']['university_id'],
          college: json['author']['college'],
          major: json['author']['major'],
          createdAt: json['author']['created_at'],
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post': post?.toJson(),
      'author': author?.toJson(),
    };
  }
}

class NotificationResponse {
  final List<NotificationModel> data;

  NotificationResponse({
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: (json['data'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
