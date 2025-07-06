// dio_client.dart

import 'package:dio/dio.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class DioClient {
  static final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        // ✅ 최적화: onError 핸들러 추가
        onError: (e, handler) async {
          // 401 에러(인증 실패)가 발생했을 때
          if (e.response?.statusCode == 401) {
            // 저장되어 있던 유효하지 않은 토큰을 삭제합니다.
            await SecureStorage.deleteToken();
            print('[DioClient] ❌ 401 Unauthorized. 토큰을 삭제합니다.');
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get dio => _dio;
}