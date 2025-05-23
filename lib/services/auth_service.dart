// auth_service.dart
// Dio 패키지: HTTP 통신을 간편하게 처리할 수 있게 해주는 Flutter의 대표적인 네트워킹 라이브러리
import 'package:dio/dio.dart';
// Flutter UI 요소 접근을 위해 필요 (예: Navigator 사용 시 필요)
import 'package:flutter/material.dart';
// 서버 주소와 API 경로가 정의된 설정 파일
import 'package:jeonmattaeng/config/api_config.dart';
// 카카오 로그인 SDK 연동한 로그인 로직이 정의된 서비스 클래스
import 'package:jeonmattaeng/services/kakao_login_service.dart';
// JWT 토큰 저장/불러오기를 위한 보안 저장소 유틸리티
import 'package:jeonmattaeng/utils/secure_storage.dart';
// Dio 설정을 캡슐화한 커스텀 Dio 클라이언트
import 'package:jeonmattaeng/services/dio_client.dart';
/// 인증 관련 로직을 모아둔 클래스 (로그인, 로그아웃 등)
class AuthService {
  // 공통적으로 사용할 Dio 인스턴스 (interceptor 등 설정된 Dio 객체)
  static final Dio _dio = DioClient.dio;

  /// 카카오 로그인 → 서버 인증 → JWT 저장 까지를 처리하는 함수
  static Future<bool> loginWithKakao(BuildContext context) async {
    // 1. 카카오 SDK를 통해 로그인 시도 → access token 반환
    final token = await KakaoLoginService.login();

    if (token == null) {
      print('[AuthService] ❌ 카카오 로그인 실패 (token == null)');
      return false;
    }

    print('[AuthService] ✅ 카카오 로그인 성공. accessToken: ${token.accessToken}');

    try {
      print('[AuthService] 🔄 서버에 accessToken 전송 중...');
      final response = await _dio.post(
        ApiConfig.kakaoLogin,
        data: {'accessToken': token.accessToken},
      );
      print('[AuthService] ✅ 서버 응답: ${response.data}');

      final jwt = response.data['token'];
      if (jwt == null) {
        print('[AuthService] ❌ JWT 없음 (response에 token 키가 없음)');
        return false;
      }

      await SecureStorage.saveToken(jwt);
      print('[AuthService] ✅ JWT 저장 완료');
      return true;

    } catch (e) {
      print('[AuthService] ❌ 서버 통신 실패: $e');
      return false;
    }
  }
  /// JWT 유효성 검증용 API 호출 (GET /auth/verify)
  static Future<void> verifyJwt() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/auth/verify');
      print('[AuthService] ✅ JWT 검증 성공: ${response.data}');
    } catch (e) {
      print('[AuthService] ❌ JWT 검증 실패: $e');
    }
  }
  static Future<bool> deleteAccount() async {
    try {
      final response = await _dio.delete('${ApiConfig.baseUrl}/user'); // 예시 경로
      print('[AuthService] ✅ 회원 탈퇴 성공: ${response.statusCode}');
      return true;
    } catch (e) {
      print('[AuthService] ❌ 회원 탈퇴 실패: $e');
      return false;
    }
  }
}