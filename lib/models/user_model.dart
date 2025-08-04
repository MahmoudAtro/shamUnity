class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String email;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.email,
    required this.phone,
  });

  // يمكنك أيضًا إضافة factory للتحويل من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'email': email,
        'phone': phone,
      };
}
