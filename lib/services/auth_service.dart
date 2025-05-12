import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/services/kakao_login_service.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class AuthService {
  static final Dio _dio = Dio();

  static Future<bool> loginWithKakao(BuildContext context) async {
    final token = await KakaoLoginService.login();
    if (token == null) {
      print('[AuthService] 카카오 로그인 실패');
      return false;
    }

    try {
      final response = await _dio.post(
        ApiConfig.kakaoLogin,
        data: {'accessToken': token.accessToken},
      );

      final jwt = response.data['token'];
      await SecureStorage.saveToken(jwt);
      print('[AuthService] 서버에서 발급된 JWT: $jwt');
      return true;
    } catch (e) {
      print('[AuthService] 서버 통신 실패: $e');
      return false;
    }
  }
}
