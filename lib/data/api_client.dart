// lib/data/api_client.dart

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _inner;
  final FirebaseAuth _firebaseAuth;

  // 1. Убедитесь, что здесь НЕТ слэша в конце
  final String _baseUrl = 'https://b795eb75e4aa.ngrok-free.app';

  ApiClient(this._inner, this._firebaseAuth);

  Uri _buildUri(String path) {

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$_baseUrl/$cleanPath');
  }

  Future<Map<String, String>> _getHeaders() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован в Firebase');
    final token = await user.getIdToken();

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final url = _buildUri(path);
    final headers = await _getHeaders();
    print('--- API CLIENT: GET $url');
    final response = await _inner.get(url, headers: headers); // <-- Добавим переменную
    // --- ЛОГИРОВАНИЕ ОТВЕТА ---
    print('--- API CLIENT: GET Response: ${response.statusCode}');
    print('--- API CLIENT: GET Response Body: ${response.body}');
    // -------------------------
    return response;
  }

  Future<http.Response> post(String path, {required Map<String, dynamic> body}) async {
    final url = _buildUri(path);
    final headers = await _getHeaders();
    final encodedBody = jsonEncode(body);
    print('--- API CLIENT: POST $url, body: $encodedBody');
    return await _inner.post(url, headers: headers, body: encodedBody);
  }

  Future<http.Response> patch(String path, {required Map<String, dynamic> body}) async {
    final url = _buildUri(path);
    final headers = await _getHeaders();
    final encodedBody = jsonEncode(body);
    print('--- API CLIENT: PATCH $url, body: $encodedBody');
    return await _inner.patch(url, headers: headers, body: encodedBody);
  }

  Future<http.Response> delete(String path) async {
    final url = _buildUri(path);
    final headers = await _getHeaders();
    print('--- API CLIENT: DELETE $url');
    return await _inner.delete(url, headers: headers);
  }
}