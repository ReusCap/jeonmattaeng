// auth_service.dart (최적화 후)

import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // debugPrint 사용
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/services/kakao_login_service.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/services/dio_client.dart';

class AuthService {
  static final Dio _dio = DioClient.dio;

  // ✅ 1. isLoggedIn() 메서드 추가 (SplashPage에서 사용)
  /// 앱 시작 시 사용자의 로그인 상태를 확인하는 메서드
  static Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      return false; // 토큰이 없으면 비로그인 상태
    }
    // 토큰이 있는 경우, 서버에 유효한지 검증
    return await verifyJwt();
  }

  // ✅ 2. loginWithKakao() 메서드에서 불필요한 파라미터 제거
  /// 카카오 로그인 및 서버 인증 처리
  static Future<bool> loginWithKakao() async { // BuildContext context 제거
    final token = await KakaoLoginService.login();

    if (token == null) {
      debugPrint('[AuthService] ❌ 카카오 로그인 실패 (token == null)');
      return false; // 실패 시 false 반환으로 통일
    }

    debugPrint('[AuthService] ✅ accessToken: ${token.accessToken}');

    try {
      final response = await _dio.post(
        ApiConfig.kakaoLogin,
        data: {'accessToken': token.accessToken},
      );

      final jwt = response.data['token'];
      if (jwt == null) {
        debugPrint('[AuthService] ❌ 서버 응답에 JWT 토큰이 없습니다.');
        return false;
      }

      await SecureStorage.saveToken(jwt);
      return true;
    } on DioException catch (e) { // DioError 대신 DioException 사용 (최신 버전)
      debugPrint('[AuthService] ❌ 서버 통신 실패: $e');
      return false;
    } catch (e) {
      debugPrint('[AuthService] ❌ 알 수 없는 에러: $e');
      return false;
    }
  }

  // ✅ 3. verifyJwt() 메서드 개선
  /// 저장된 JWT 토큰의 유효성을 서버에 검증하는 메서드
  static Future<bool> verifyJwt() async {
    try {
      // DioClient에 인터셉터가 설정되어 있으므로, 헤더를 명시할 필요 없음
      await _dio.get('${ApiConfig.baseUrl}/auth/verify');
      debugPrint('[AuthService] ✅ JWT 토큰 유효함.');
      return true;
    } catch (e) {
      debugPrint('[AuthService] ❌ JWT 검증 실패: $e');
      // dio_client의 onError 인터셉터가 토큰을 삭제하지만, 여기서 한 번 더 확인사살
      await SecureStorage.deleteToken();
      return false;
    }
  }

  /// 회원 탈퇴
  static Future<bool> deleteAccount() async {
    try {
      await _dio.delete(ApiConfig.deleteAccount);
      debugPrint('[AuthService] ✅ 회원 탈퇴 성공');
      // 탈퇴 성공 시 로컬 토큰도 삭제
      await SecureStorage.deleteToken();
      return true;
    } catch (e) {
      debugPrint('[AuthService] ❌ 회원 탈퇴 실패: $e');
      return false;
    }
  }
}