// lib/models/user_model.dart

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 앱 내에서 사용하는 사용자 모델
class UserModel {
  final String id;
  final String email;
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  /// 📥 서버 응답 JSON → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  /// 📤 UserModel → 서버 전송용 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  /// 📥 카카오 User 객체 → UserModel
  factory UserModel.fromKakaoUser(User user) {
    return UserModel(
      id: user.id?.toString() ?? '',
      email: user.kakaoAccount?.email ?? '',
      name: user.kakaoAccount?.profile?.nickname ?? '',
    );
  }
}
