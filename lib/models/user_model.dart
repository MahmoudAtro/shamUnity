class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String email;
  final String phone;
  final String university;
  final String academicYear;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.university,
    required this.academicYear,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      university: json['university'] ?? '',
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'email': email,
        'phone': phone,
        'university': university,
        'academicYear': academicYear,
      };
}
