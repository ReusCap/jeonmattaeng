class Review {
  final String id;
  final String userNickname;
  final String userProfileImage;
  final String content;
  final DateTime createdAt;
  final String authorId;

  Review({
    required this.id,
    required this.userNickname,
    required this.userProfileImage,
    required this.content,
    required this.createdAt,
    required this.authorId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final author = json['authorId'] ?? {};
    return Review(
      id: json['_id']?.toString() ?? '',
      userNickname: author['nickname'] ?? '',
      userProfileImage: author['profileImage'] ?? '',
      content: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      authorId: author['_id'] ?? '',
    );
  }

  /// 클라이언트 측에서 현재 로그인한 유저 ID를 넘겨 비교
  bool isMine(String myUserId) {
    return authorId == myUserId;
  }
}
