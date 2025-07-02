import 'dart:convert';

class JwtUtils {
  /// JWT에서 유저 ID(_id)를 추출
  static String? extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(base64Url.decode(base64.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);

      return data['_id'];
    } catch (_) {
      return null;
    }
  }
}
