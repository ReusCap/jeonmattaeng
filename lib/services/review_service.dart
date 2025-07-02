// lib/services/review_service.dart (최종 수정본)

import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/review_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:flutter/material.dart'; // debugPrint 사용

class ReviewService {
  static final Dio _dio = DioClient.dio;

  /// 🔍 특정 메뉴의 리뷰 목록 불러오기
  static Future<List<Review>> getReviews(String menuId) async {
    try {
      // ✅ ApiConfig의 통합된 메서드 호출
      final response = await _dio.get(ApiConfig.reviewsByMenu(menuId));
      debugPrint('[ReviewService] 리뷰 목록(${menuId}) 불러오기 성공');
      return (response.data as List)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[ReviewService] 리뷰 목록(${menuId}) 불러오기 실패: $e');
      rethrow;
    }
  }

  /// ✏️ 리뷰 작성
  static Future<void> postReview(String menuId, String content) async {
    try {
      // ✅ ApiConfig의 통합된 메서드 호출
      await _dio.post(
        ApiConfig.reviewsByMenu(menuId),
        data: {'content': content}, // API 명세에 따라 'body' 또는 'content' 사용
      );
      debugPrint('[ReviewService] 리뷰(${menuId}) 등록 성공');
    } catch (e) {
      debugPrint('[ReviewService] 리뷰(${menuId}) 등록 실패: $e');
      rethrow;
    }
  }

  /// ❌ 리뷰 삭제
  static Future<void> deleteReview(String reviewId) async {
    try {
      await _dio.delete(ApiConfig.deleteReview(reviewId));
      debugPrint('[ReviewService] 리뷰 삭제(${reviewId}) 성공');
    } catch (e) {
      debugPrint('[ReviewService] 리뷰 삭제(${reviewId}) 실패: $e');
      rethrow;
    }
  }
}