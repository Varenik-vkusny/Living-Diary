// lib/domain/repositories/diary_repository.dart
import '../entities/note_entity.dart';

abstract class DiaryRepository {
  Future<List<NoteEntity>> getNotes();
  Future<void> createNote({required String title, required String content});
  Future<void> updateNote({required int noteId, String? title, String? content});
}