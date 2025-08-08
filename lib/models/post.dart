class PostModel {
  final String userName;
  final String userAvatarUrl;
  final String postTime;
  final String postText;
  final String? postImageUrl;

  PostModel({
    required this.userName,
    required this.userAvatarUrl,
    required this.postTime,
    required this.postText,
    this.postImageUrl,
  });


  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      postTime: json['postTime'] as String,
      postText: json['postText'] as String,
      postImageUrl: json['postImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'postTime': postTime,
      'postText': postText,
      'postImageUrl': postImageUrl,
    };
  }
}
