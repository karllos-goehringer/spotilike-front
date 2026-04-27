class User{
  final int id;
  final String name;
  final String email;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['PK_userID'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }
}