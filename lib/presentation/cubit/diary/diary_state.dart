// lib/presentation/cubit/diary/diary_state.dart
import '../../../domain/entities/diary/note_entity.dart';

abstract class DiaryState {}

class DiaryInitial extends DiaryState {}

class DiaryLoading extends DiaryState {}

// Состояние успешной загрузки списка заметок
class DiaryLoaded extends DiaryState {
  final List<NoteEntity> notes;
  DiaryLoaded(this.notes);
}

// Состояние успешного выполнения действия (создание, обновление, удаление)
class DiarySuccess extends DiaryState {}

// Состояние ошибки
class DiaryFailure extends DiaryState {
  final String message;
  DiaryFailure(this.message);
}