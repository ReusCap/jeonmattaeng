import 'package:dio/dio.dart';
import 'package:jeonmattaeng/models/comment_model.dart';
import 'package:jeonmattaeng/services/dio_client.dart';
import 'package:jeonmattaeng/config/api_config.dart';

class CommentService {
  static final Dio _dio = DioClient.dio; // ✅ 인터셉터 설정된 Dio

  /// 🔍 특정 메뉴의 댓글 리스트 불러오기
  static Future<List<Comment>> getComments(int menuId) async {
    try {
      final response = await _dio.get(ApiConfig.comments(menuId));

      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      print('[CommentService] 댓글 불러오기 실패: $e');
      rethrow;
    }
  }

  /// ✏️ 댓글 작성
  static Future<void> postComment(int menuId, String content) async {
    try {
      await _dio.post(
        ApiConfig.comments(menuId),
        data: {'content': content},
      );
    } catch (e) {
      print('[CommentService] 댓글 등록 실패: $e');
      rethrow;
    }
  }
}
