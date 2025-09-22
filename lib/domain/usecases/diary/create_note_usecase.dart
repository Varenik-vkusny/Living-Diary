import '../../repositories/diary_repository.dart';


class CreateNoteUseCase {
  final DiaryRepository repository;
  CreateNoteUseCase(this.repository);

  Future<void> call({required String title, required String content}) {
    if (title.isEmpty || content.isEmpty) {
      throw Exception('Заголовок и содержание не могут быть пустыми');
    }
    return repository.createNote(title: title, content: content);
  }
}