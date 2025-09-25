// lib/data/repository/diary_repository_impl.dart
import '../../../domain/entities/diary/note_entity.dart';
import '../../../domain/repositories/diary/diary_repository.dart';
import '../../datasources/diary/diary_remote_data_source.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;

  DiaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NoteEntity> createNote({required String title, required String content}) async {
    // DataSource возвращает NoteModel, а мы должны вернуть NoteEntity.
    // Так как NoteModel наследуется от NoteEntity, преобразование происходит автоматически.
    return await remoteDataSource.createNote(title: title, content: content);
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    return await remoteDataSource.getNotes();
  }

  @override
  Future<NoteEntity> updateNote({required int noteId, String? title, String? content}) async {
    return await remoteDataSource.updateNote(noteId: noteId, title: title, content: content);
  }

  @override
  Future<void> deleteNote({required int noteId}) async {
    return await remoteDataSource.deleteNote(noteId: noteId);
  }
}