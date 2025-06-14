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
    final token = await KakaoLoginService.login();

    if (token == null) {
      print('[AuthService] ❌ 카카오 로그인 실패 (token == null)');
      throw Exception('카카오 로그인 실패 (token 없음)');
    }

    print('[AuthService] ✅ accessToken: ${token.accessToken}');

    try {
      final response = await _dio.post(
        ApiConfig.kakaoLogin,
        data: {'accessToken': token.accessToken},
      );
      print('[AuthService] ✅ 서버 응답: ${response.data}');

      final jwt = response.data['token'];
      if (jwt == null) {
        throw Exception('JWT 토큰 없음 (백엔드 응답 오류)');
      }

      await SecureStorage.saveToken(jwt);
      return true;
    } catch (e) {
      print('[AuthService] ❌ 서버 통신 실패: $e');
      throw Exception('서버 인증 실패: $e');
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
  /// 회원 탈퇴
  static Future<bool> deleteAccount() async {
    try {
      final response = await DioClient.dio.delete(ApiConfig.deleteAccount);
      print('[AuthService] ✅ 회원 탈퇴 성공: ${response.statusCode}');
      return true;
    } catch (e) {
      print('[AuthService] ❌ 회원 탈퇴 실패: $e');
      return false;
    }
  }
}