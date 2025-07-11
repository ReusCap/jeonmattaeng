// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/services/kakao_login_service.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/services/dio_client.dart';

class AuthService {
  static final Dio _dio = DioClient.dio;

  /// 앱 시작 시 사용자의 로그인 상태를 확인하는 메서드
  static Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      return false;
    }
    return await verifyJwt();
  }

  /// 카카오 로그인 및 서버 인증 처리
  static Future<bool> loginWithKakao() async {
    final token = await KakaoLoginService.login();

    if (token == null) {
      debugPrint('[AuthService] ❌ 카카오 로그인 실패 (token == null)');
      return false;
    }

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
    } on DioException catch (e) {
      debugPrint('[AuthService] ❌ 서버 통신 실패: $e');
      return false;
    } catch (e) {
      debugPrint('[AuthService] ❌ 알 수 없는 에러: $e');
      return false;
    }
  }

  /// 저장된 JWT 토큰의 유효성을 서버에 검증하는 메서드
  static Future<bool> verifyJwt() async {
    try {
      await _dio.get(ApiConfig.verifyJwt);
      debugPrint('[AuthService] ✅ JWT 토큰 유효함.');
      return true;
    } catch (e) {
      debugPrint('[AuthService] ❌ JWT 검증 실패: $e');
      await SecureStorage.deleteToken();
      return false;
    }
  }

  /// 회원 탈퇴
  static Future<bool> deleteAccount() async {
    try {
      await _dio.delete(ApiConfig.deleteAccount);
      debugPrint('[AuthService] ✅ 회원 탈퇴 성공');
      await SecureStorage.deleteToken();
      return true;
    } catch (e) {
      debugPrint('[AuthService] ❌ 회원 탈퇴 실패: $e');
      return false;
    }
  }
}