class Post {
  final int id;
  bool isLiked;
  final String content;
  final String? imageUrl; // تغيير من imagePath إلى imageUrl
  final int likesCount;
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
      imageUrl: json['image_url'], // تغيير من image_path إلى image_url
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      createdAt: json['created_at'], // إبقاؤه كنص أو تحويله إلى DateTime
      author: Author.fromJson(json['author']),
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

  // باقي الدوال (toJson, copyWith) تحتاج إلى تعديل مشابه
}

class Author {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;
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
    this.profilePicture,
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      postsCount: json['posts_count'],
      commentsCount: json['comments_count'],
      likesCount: json['likes_count'],
      gender: json['gender'],
      birthDate: json['birth_date'], // إبقاؤه كنص أو تحويله إلى DateTime
      universityId: json['university_id'],
      college: json['college'],
      major: json['major'],
      createdAt: json['created_at'], // إبقاؤه كنص أو تحويله إلى DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
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
