class User {
  final String id;
  final String nickname;
  final String profileImageUrl;

  User({
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nickname: json['nickname'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
