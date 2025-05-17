// secure_storage.dart
// Flutter 앱에서 민감한 정보를 안전하게 저장할 수 있게 해주는 패키지 (Android/iOS 보안 저장소 사용)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 앱 내에서 JWT 토큰을 안전하게 저장/불러오기 위한 유틸리티 클래스
class SecureStorage {
  // 보안 저장소 인스턴스 생성 (싱글톤처럼 사용)
  static final _storage = FlutterSecureStorage();

  // 저장할 키 이름 (해당 키에 토큰 값을 저장함)
  static const _jwtKey = 'jwt_token';

  /// JWT 토큰 저장 함수
  /// [token]: 저장할 JWT 문자열
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  /// JWT 토큰 불러오기 함수
  /// 저장된 토큰이 없으면 null 반환
  static Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  /// JWT 토큰 삭제 함수
  /// 로그아웃 시 호출
  static Future<void> deleteToken() async {
    await _storage.delete(key: _jwtKey);
  }
}
