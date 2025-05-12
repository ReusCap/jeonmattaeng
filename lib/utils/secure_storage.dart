import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _jwtKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _jwtKey);
  }
}
