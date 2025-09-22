// lib/data/repositories/diary_repository_impl.dart

import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_remote_data_source.dart';


class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;

  DiaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createNote({required String title, required String content}) {
    return remoteDataSource.createNote(title: title, content: content);
  }

  @override
  Future<List<NoteEntity>> getNotes() {
    return remoteDataSource.getNotes();
  }

  @override
  Future<void> updateNote({required int noteId, String? title, String? content}) {
    throw UnimplementedError();
  }
}