class UserMessage {
  final int id;
  final String name;
  final String? profilePictureUrl;

  UserMessage({required this.id, required this.name, this.profilePictureUrl});

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      id: json['id'],
      name: json['name'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}
