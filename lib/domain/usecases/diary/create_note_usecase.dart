// lib/domain/usecases/diary/create_note_usecase.dart
import '../../entities/diary/note_entity.dart';
import '../../repositories/diary/diary_repository.dart';

class CreateNoteUseCase {
  final DiaryRepository repository;

  CreateNoteUseCase(this.repository);

  Future<NoteEntity> call({required String title, required String content}) async {
    return await repository.createNote(title: title, content: content);
  }
}