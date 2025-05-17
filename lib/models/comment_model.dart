class Comment {
  final int id;
  final String content;
  final String userName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userName: json['userName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
