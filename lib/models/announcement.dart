class Announcement {
  final int id;
  final String? content;
  final String? fileType;
  final String? fileUrl;
  final String createdAt;

  Announcement({
    required this.id,
    this.content,
    this.fileType,
    this.fileUrl,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      content: json['content'],
      fileType: json['file_type'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'file_type': fileType,
      'file_url': fileUrl,
      'created_at': createdAt,
    };
  }
}
