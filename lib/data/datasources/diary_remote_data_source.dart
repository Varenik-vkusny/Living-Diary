import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_client.dart';
import '../models/note_model.dart';

abstract class DiaryRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> createNote({required String title, required String content});
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final ApiClient _client;
  final FirebaseAuth _firebaseAuth;

  DiaryRemoteDataSourceImpl(this._client, this._firebaseAuth);

  @override
  Future<void> createNote({required String title, required String content}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) throw Exception('Пользователь не авторизован');

    final body = jsonEncode({
      'title': title,
      'content': content,
      'user_uid': currentUser.uid,
    });

    final response = await _client.post(
      Uri.parse('/notes/'),  // ApiClient сам добавит базовый URL
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка создания заметки: ${response.body}');
    }
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    // Реализация получения заметок
    throw UnimplementedError();
  }
}