// lib/data/datasources/diary_remote_data_source.dart

import 'dart:convert';
import 'package:living_diary/data/api_client.dart';

import '../../models/diary/note_model.dart';

abstract class DiaryRemoteDataSource {
  Future<NoteModel> createNote({required String title, required String content});
  Future<List<NoteModel>> getNotes();
  Future<NoteModel> updateNote({required int noteId, String? title, String? content});
  Future<void> deleteNote({required int noteId});
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final ApiClient _apiClient;
  final String _notesCollectionPath = '/notes/';
  final String _singleNotePath = '/notes';

  DiaryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<NoteModel> createNote({required String title, required String content}) async {
    final noteToSend = NoteModel(title: title, content: content);
    final response = await _apiClient.post(_notesCollectionPath, body: noteToSend.toJson());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания заметки: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await _apiClient.get(_notesCollectionPath);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => NoteModel.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка получения заметок: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<NoteModel> updateNote({required int noteId, String? title, String? content}) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;

    final response = await _apiClient.patch('$_singleNotePath/$noteId', body: body);

    if (response.statusCode == 200) {
      return NoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка обновления заметки: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<void> deleteNote({required int noteId}) async {
    final response = await _apiClient.delete('$_singleNotePath/$noteId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Ошибка удаления заметки: ${response.statusCode} ${response.body}');
    }
  }
}