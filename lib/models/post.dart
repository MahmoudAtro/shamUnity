class Post {
  final int id;
  bool isLiked;
  final String content;
  final String? imageUrl; // تغيير من imagePath إلى imageUrl
  int likesCount; // Remove final to allow modification
  final int commentsCount;
  final String createdAt; // تغيير من DateTime إلى String (أو معالجة النص)
  final Author author;

  Post({
    this.isLiked = false,
    required this.id,
    required this.content,
    this.imageUrl, // تغيير من imagePath إلى imageUrl
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt, // تغيير من DateTime إلى String
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      imageUrl: json['image_url'], // This can be null
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      author: json['author'] != null
          ? Author.fromJson(json['author'])
          : Author.empty(), // Handle null author
      isLiked:
          json['is_liked_by_user'] ?? false, // Get isLiked from API response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'image_url': imageUrl, // تم التعديل من imagePath إلى imageUrl
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt, // تم تغيير النوع إلى String
      'author': author.toJson(),
      'is_liked_by_user': isLiked, // إضافة isLiked
    };
  }

  Post copyWith({
    int? id,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    String? createdAt,
    Author? author,
    bool? isLiked,
  }) {
    return Post(
      isLiked: isLiked ?? this.isLiked,
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }

  // Method to toggle like state - DEPRECATED: Use server response instead
  @Deprecated('Use server response instead of local toggle')
  void toggleLike() {
    isLiked = !isLiked;
    if (isLiked) {
      likesCount++;
    } else {
      likesCount--;
    }
  }
}

class Author {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final int? postsCount; // جعله nullable
  final int? commentsCount; // جعله nullable
  final int? likesCount; // جعله nullable
  final String? gender; // جعله nullable
  final String?
      birthDate; // جعله nullable (أو تحويله إلى DateTime إذا كان الـ API يرسل تنسيقًا مختلفًا)
  final String? universityId; // جعله nullable
  final String? college; // جعله nullable
  final String? major; // جعله nullable
  final String createdAt; // تغيير من DateTime إلى String

  Author({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.postsCount,
    this.commentsCount,
    this.likesCount,
    this.gender,
    this.birthDate,
    this.universityId,
    this.college,
    this.major,
    required this.createdAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profile_picture'],
      postsCount: json['posts_count'],
      commentsCount: json['comments_count'],
      likesCount: json['likes_count'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      universityId: json['university_id'],
      college: json['college'],
      major: json['major'],
      createdAt: json['created_at'] ?? '',
    );
  }

  // Factory method for creating an empty author when data is not available
  factory Author.empty() {
    return Author(
      id: 0,
      name: '',
      email: '',
      profilePictureUrl: null,
      postsCount: 0,
      commentsCount: 0,
      likesCount: 0,
      gender: null,
      birthDate: null,
      universityId: null,
      college: null,
      major: null,
      createdAt: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePictureUrl,
      'posts_count': postsCount,
      'comments_count': commentsCount,
      'likes_count': likesCount,
      'gender': gender,
      'birth_date': birthDate, // يمكن تحويله إلى String إذا كان نوعه DateTime
      'university_id': universityId,
      'college': college,
      'major': major,
      'created_at': createdAt, // تم تغيير النوع إلى String
    };
  }
}
