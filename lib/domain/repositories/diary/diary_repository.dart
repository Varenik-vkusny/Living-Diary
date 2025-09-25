// lib/domain/repositories/diary_repository.dart
import '../../entities/diary/note_entity.dart';

abstract class DiaryRepository {
  Future<NoteEntity> createNote({required String title, required String content});
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> updateNote({required int noteId, String? title, String? content});
  Future<void> deleteNote({required int noteId});
}