class Comment {
  final String id;
  final String userNickname;
  final String userProfileImage;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userNickname,
    required this.userProfileImage,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userNickname: json['userNickname'],
      userProfileImage: json['userProfileImage'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
