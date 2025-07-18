// lib/services/dio_client.dart

import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class DioClient {
  // ✅ BaseOptions를 사용하여 Dio의 기본 설정을 명시적으로 관리합니다.
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl, // .env 등에서 불러온 기본 URL
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onError: (e, handler) async {
        print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');

        // 401 에러(인증 실패)가 발생했을 때
        if (e.response?.statusCode == 401) {
          // 저장되어 있던 유효하지 않은 토큰을 자동으로 삭제합니다.
          await SecureStorage.deleteToken();
          print('[DioClient] ❌ 401 Unauthorized. 토큰이 삭제되었습니다.');
        }
        return handler.next(e);
      },
    ),
  );

  static Dio get dio => _dio;
}