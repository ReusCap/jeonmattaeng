// auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // debugPrint 사용
import 'package:image_picker/image_picker.dart'; // ✨ 이미지 업로드를 위해 추가
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/services/kakao_login_service.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  static final Dio _dio = DioClient.dio;

  // 1. isLoggedIn() 메서드 (SplashPage에서 사용)
  /// 앱 시작 시 사용자의 로그인 상태를 확인하는 메서드
  static Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      return false; // 토큰이 없으면 비로그인 상태
    }
    // 토큰이 있는 경우, 서버에 유효한지 검증
    return await verifyJwt();
  }

  // 2. loginWithKakao() 메서드
  /// 카카오 로그인 및 서버 인증 처리
  static Future<bool> loginWithKakao() async {
    final token = await KakaoLoginService.login();

    if (token == null) {
      debugPrint('[AuthService] ❌ 카카오 로그인 실패 (token == null)');
      return false;
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
    } on DioException catch (e) {
      debugPrint('[AuthService] ❌ 서버 통신 실패: $e');
      return false;
    } catch (e) {
      debugPrint('[AuthService] ❌ 알 수 없는 에러: $e');
      return false;
    }
  }

  // 3. verifyJwt() 메서드
  /// 저장된 JWT 토큰의 유효성을 서버에 검증하는 메서드
  static Future<bool> verifyJwt() async {
    try {
      await _dio.get(ApiConfig.verifyJwt); // ✨ API 경로 수정
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

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConfig.userInfo);
      return response.data;
    } on DioException catch (e) {
      debugPrint('[AuthService] ❌ getUserProfile 실패: $e');
      return null;
    }
  }

  // 닉네임 변경하기
  static Future<void> updateNickname(String nickname) async {
    try {
      await _dio.post(
        ApiConfig.updateNickname,
        data: {'nickname': nickname},
      );
      debugPrint('[AuthService] ✅ 닉네임 변경 성공');
    } on DioException catch (e) {
      debugPrint('[AuthService] ❌ updateNickname 실패: $e');
      rethrow; // 에러를 다시 던져서 Provider에서 처리하게 함
    }
  }

  // 프로필 이미지 업로드하기
  // 프로필 이미지를 서버에 업로드하고 URL을 반환합니다.
  static Future<String?> updateProfileImage(XFile image) async {
    // 디버깅을 위해 서버로 보내는 파일 정보를 출력합니다.
    debugPrint('--- 서버로 보내는 파일 정보 ---');
    debugPrint('파일 경로 (Path): ${image.path}');
    debugPrint('파일 이름 (Name): ${image.name}');

    final mimeType = lookupMimeType(image.path);
    debugPrint('찾아낸 MIME 타입 (MimeType): $mimeType');
    debugPrint('--------------------------');

    try {
      final formData = FormData.fromMap({
        'profileImg': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
          // ContentType을 명시적으로 지정합니다.
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final response = await _dio.post(
        ApiConfig.updateProfileImg,
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('[AuthService] ✅ 프로필 이미지 업로드 성공');
        return response.data['profileImgUrl'];
      }
      return null;

    } on DioException catch (e) {
      debugPrint('[AuthService] ❌ updateProfileImage 실패: $e');
      return null;
    }
  }
}