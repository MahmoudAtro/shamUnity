class LibraryFile {
  final int id;
  final String title;
  final String filePath;
  final String type;
  final String status;
  final int userId;
  final int courseId;
  final int? processedByUserId;
  final String createdAt;
  final String updatedAt;

  LibraryFile({
    required this.id,
    required this.title,
    required this.filePath,
    required this.type,
    required this.status,
    required this.userId,
    required this.courseId,
    required this.processedByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LibraryFile.fromJson(Map<String, dynamic> json) {
    return LibraryFile(
      id: json['id'],
      title: json['title'],
      filePath: json['file_path'],
      type: json['type'],
      status: json['status'],
      userId: json['user_id'],
      courseId: json['course_id'],
      processedByUserId: json['processed_by_user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'type': type,
      'status': status,
      'user_id': userId,
      'course_id': courseId,
      'processed_by_user_id': processedByUserId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
