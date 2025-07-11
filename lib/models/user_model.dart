// user_model.dart (수정본)

class User {
  final String id;
  final String nickname;
  final String profileImageUrl;

  User({
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
  });

  // ✅ 1. 서버 응답 키에 맞게 수정
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '', // _id 키 사용
      nickname: json['nickname'] ?? '익명',
      profileImageUrl: json['profileImage'] ?? '', // profileImage 키 사용
    );
  }

  // ✅ 2. 상태 업데이트를 위한 copyWith 메서드 추가
  User copyWith({
    String? id,
    String? nickname,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}