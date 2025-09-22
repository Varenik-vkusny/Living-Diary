// lib/data/api_client.dart



import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// lib/data/api_client.dart

import 'package:firebase_auth/firebase_auth.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner;
  final FirebaseAuth _firebaseAuth;

  // 1. УКАЗЫВАЕМ ТОЛЬКО БАЗОВЫЙ URL, БЕЗ ЭНДПОИНТОВ
  final String _baseUrl = 'https://07483d6cb060.ngrok-free.app';

  ApiClient(this._inner, this._firebaseAuth);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final token = await user.getIdToken(true);
      request.headers['Authorization'] = 'Bearer $token';

      // 2. НАДЕЖНАЯ СБОРКА URL
      final url = Uri.parse('$_baseUrl${request.url}');

      final newRequest = http.Request(request.method, url)
        ..headers.addAll(request.headers);

      if (request is http.Request) {
        newRequest.bodyBytes = request.bodyBytes;
      }

      print('--- API CLIENT: Отправка запроса на: ${newRequest.url}');
      print('--- API CLIENT: Заголовки: ${newRequest.headers}');

      return _inner.send(newRequest);
    } catch (e) {
      rethrow;
    }
  }
}