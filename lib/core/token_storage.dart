// lib/core/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _key = 'auth_jwt_token'; // Ключ для хранения токена

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
    print('--- TOKEN STORAGE: Токен сохранен.');
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _key);
    print('--- TOKEN STORAGE: Токен получен: ${token != null ? "Да" : "Нет"}.');
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _key);
    print('--- TOKEN STORAGE: Токен удален.');
  }
}