import 'dart:io';

class BookRequestModel {
  final String title;

  final int courseId;
  final File? file;

  BookRequestModel({
    required this.title,
    required this.courseId,
    this.file,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'course_id': courseId,
      if (file != null) 'file': file,
    };
  }
}

class BookRequestResponse {
  final String message;
  final bool success;
  final BookRequestData? data;

  BookRequestResponse({
    required this.message,
    required this.success,
    this.data,
  });

  factory BookRequestResponse.fromJson(Map<String, dynamic> json) {
    return BookRequestResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data:
          json['data'] != null ? BookRequestData.fromJson(json['data']) : null,
    );
  }
}

class BookRequestData {
  final int id;
  final String title;
  final String type;
  final int courseId;
  final String? filePath;
  final String status;
  final String createdAt;

  BookRequestData({
    required this.id,
    required this.title,
    required this.type,
    required this.courseId,
    this.filePath,
    required this.status,
    required this.createdAt,
  });

  factory BookRequestData.fromJson(Map<String, dynamic> json) {
    return BookRequestData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      courseId: json['course_id'] ?? 0,
      filePath: json['file_path'],
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
