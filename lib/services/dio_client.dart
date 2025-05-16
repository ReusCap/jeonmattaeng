import 'package:dio/dio.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class DioClient {
  static final Dio _dio = Dio()
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken(); // JWT 불러오기
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          // 에러 처리 필요 시
          return handler.next(e);
        },
      ),
    );

  static Dio get dio => _dio;
}
