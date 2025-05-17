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

    // 2. 실패 시 로그 출력 및 false 반환
    if (token == null) {
      print('[AuthService] 카카오 로그인 실패');
      return false;
    }

    try {
      // 3. accessToken을 서버에 POST 요청으로 전달
      final response = await _dio.post(
        ApiConfig.kakaoLogin, // ex: http://서버주소/auth/kakao
        data: {'accessToken': token.accessToken}, // Body에 토큰 포함
      );

      // 4. 서버로부터 JWT 응답 받기
      final jwt = response.data['token'];

      // 5. secure storage에 JWT 저장
      await SecureStorage.saveToken(jwt);

      print('[AuthService] 서버에서 발급된 JWT: $jwt');

      // 6. 로그인 성공 → true 반환
      return true;
    } catch (e) {
      // 서버 통신 실패 로그 출력 후 false 반환
      print('[AuthService] 서버 통신 실패: $e');
      return false;
    }
  }
}