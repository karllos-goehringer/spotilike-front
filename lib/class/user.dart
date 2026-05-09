class User{
  final int id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? description;
  final String? backgroundImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.description,
    this.backgroundImage
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['PK_userID'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profilepicture'] ?? json['profileImageUrl'] ?? '',
      description: json['description'] ?? '',
      backgroundImage: json['backgroundimage'] ?? json['backgroundImage'] ?? '',
    );
  }
  
}