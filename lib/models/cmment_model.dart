class CommentModel {
  final String username;
  final String avatarUrl; // يمكن تركه فارغ لاستخدام حرف
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.username,
    required this.text,
    required this.timestamp,
    this.avatarUrl = '',
  });
}
