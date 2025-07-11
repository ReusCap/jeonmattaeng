// lib/services/user_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UserService {
  static final Dio _dio = DioClient.dio;

  /// 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConfig.userInfo);
      return response.data;
    } on DioException catch (e) {
      debugPrint('[UserService] ❌ getUserProfile 실패: $e');
      return null;
    }
  }

  /// 닉네임 변경하기
  static Future<void> updateNickname(String nickname) async {
    try {
      await _dio.post(
        ApiConfig.updateNickname,
        data: {'nickname': nickname},
      );
      debugPrint('[UserService] ✅ 닉네임 변경 성공');
    } on DioException catch (e) {
      debugPrint('[UserService] ❌ updateNickname 실패: $e');
      rethrow; // 에러를 다시 던져서 Provider에서 처리하게 함
    }
  }

  /// 프로필 이미지 업로드하기
  static Future<String?> updateProfileImage(XFile image) async {
    final mimeType = lookupMimeType(image.path);

    try {
      final formData = FormData.fromMap({
        'profileImg': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      });

      final response = await _dio.post(
        ApiConfig.updateProfileImg,
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('[UserService] ✅ 프로필 이미지 업로드 성공');
        return response.data['profileImgUrl'];
      }
      return null;

    } on DioException catch (e) {
      debugPrint('[UserService] ❌ updateProfileImage 실패: $e');
      return null;
    }
  }
}