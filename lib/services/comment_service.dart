import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class CommentService {
  static final Dio _dio = Dio();

  static Future<List<String>> fetchComments(int menuId) async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/menus/$menuId/comments');

      // TODO: 실제 API 연동 후 response.data로 파싱
      return (response.data as List).map((c) => c.toString()).toList();
    } catch (e) {
      print('[fetchComments] Error: $e');
      return [];
    }
  }

  static Future<bool> submitComment({required int menuId, required String comment}) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/menus/$menuId/comments',
        data: {'content': comment},
      );
      return response.statusCode == 201;
    } catch (e) {
      print('[submitComment] Error: $e');
      return false;
    }
  }
}
