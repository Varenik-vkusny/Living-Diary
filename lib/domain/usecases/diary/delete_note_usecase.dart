// lib/domain/usecases/diary/delete_note_usecase.dart
import '../../repositories/diary/diary_repository.dart';

class DeleteNoteUseCase {
  final DiaryRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<void> call({required int noteId}) async {
    await repository.deleteNote(noteId: noteId);
  }
}