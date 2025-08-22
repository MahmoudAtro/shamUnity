import 'package:shamunity/models/library_file.dart';
import 'package:shamunity/models/post.dart';

class VisitedUserProfile {
  final Author profile;
  final List<Post> posts;
  final List<LibraryFile> libraryFiles;

  VisitedUserProfile({
    required this.profile,
    required this.posts,
    required this.libraryFiles,
  });

  factory VisitedUserProfile.fromJson(Map<String, dynamic> json) {
    final profile = Author.fromJson(json['profile']);

    // إنشاء منشورات مع المؤلف من البيانات المتوفرة
    final posts = (json['posts'] as List).map((postJson) {
      // إنشاء Author لكل منشور من البيانات المتوفرة
      final postAuthor = Author(
        id: profile.id,
        name: profile.name,
        email: profile.email,
        profilePictureUrl: profile.profilePictureUrl,
        postsCount: profile.postsCount,
        commentsCount: profile.commentsCount,
        likesCount: profile.likesCount,
        gender: profile.gender,
        birthDate: profile.birthDate,
        universityId: profile.universityId,
        college: profile.college,
        major: profile.major,
        createdAt: profile.createdAt,
      );

      // إنشاء Post مع Author
      return Post(
        id: postJson['id'],
        content: postJson['content'],
        imageUrl: postJson['image_url'],
        likesCount: postJson['likes_count'],
        commentsCount: postJson['comments_count'],
        createdAt: postJson['created_at'],
        author: postAuthor,
        isLiked: postJson['is_liked_by_user'] ?? false,
      );
    }).toList();

    final libraryFiles = (json['library_files'] as List)
        .map((fileJson) => LibraryFile.fromJson(fileJson))
        .toList();

    return VisitedUserProfile(
      profile: profile,
      posts: posts,
      libraryFiles: libraryFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'posts': posts.map((post) => post.toJson()).toList(),
      'library_files': libraryFiles.map((file) => file.toJson()).toList(),
    };
  }
}
