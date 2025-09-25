// lib/domain/usecases/diary/update_note_usecase.dart
import '../../entities/diary/note_entity.dart';
import '../../repositories/diary/diary_repository.dart';

class UpdateNoteUseCase {
  final DiaryRepository repository;

  UpdateNoteUseCase(this.repository);

  Future<NoteEntity> call({required int noteId, String? title, String? content}) async {
    return await repository.updateNote(noteId: noteId, title: title, content: content);
  }
}