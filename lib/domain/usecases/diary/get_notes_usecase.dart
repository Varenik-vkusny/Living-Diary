// lib/domain/usecases/diary/get_notes_usecase.dart
import '../../entities/diary/note_entity.dart';
import '../../repositories/diary/diary_repository.dart';

class GetNotesUseCase {
  final DiaryRepository repository;

  GetNotesUseCase(this.repository);

  Future<List<NoteEntity>> call() async {
    return await repository.getNotes();
  }
}