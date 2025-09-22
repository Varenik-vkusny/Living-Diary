// lib/presentation/pages/home/cubit/diary_state.dart

abstract class DiaryState {}

// Начальное состояние, ничего не происходит
class DiaryInitial extends DiaryState {}

// Идет процесс загрузки (создание, получение, удаление заметки)
class DiaryLoading extends DiaryState {}

// Заметка была успешно создана
class DiaryCreationSuccess extends DiaryState {}

// Произошла какая-либо ошибка
class DiaryError extends DiaryState {
  final String message;
  DiaryError(this.message);
}

// TODO: В будущем можно добавить состояния для успешного получения списка заметок
// class DiaryLoaded extends DiaryState {
//   final List<NoteEntity> notes;
//   DiaryLoaded(this.notes);
// }