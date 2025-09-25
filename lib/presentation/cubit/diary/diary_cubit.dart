// lib/presentation/cubit/diary/diary_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/diary/create_note_usecase.dart';
import '../../../domain/usecases/diary/delete_note_usecase.dart';
import '../../../domain/usecases/diary/get_notes_usecase.dart';
import '../../../domain/usecases/diary/update_note_usecase.dart';
import 'diary_state.dart';

class DiaryCubit extends Cubit<DiaryState> {
  final CreateNoteUseCase createNoteUseCase;
  final GetNotesUseCase getNotesUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  DiaryCubit({
    required this.createNoteUseCase,
    required this.getNotesUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(DiaryInitial());

  Future<void> fetchNotes() async {
    try {
      emit(DiaryLoading());
      final notes = await getNotesUseCase.call();
      emit(DiaryLoaded(notes));
    } catch (e) {
      emit(DiaryFailure(e.toString()));
    }
  }




  Future<void> createNote(String title, String content) async {
    try {
      emit(DiaryLoading());
      await createNoteUseCase.call(title: title, content: content);
      emit(DiarySuccess());
      await fetchNotes();
    } catch (e) {
      emit(DiaryFailure(e.toString()));
    }
  }

  Future<void> updateNote(int noteId, {String? title, String? content}) async {
    try {
      await updateNoteUseCase.call(noteId: noteId, title: title, content: content);
      await fetchNotes();
    } catch (e) {
      emit(DiaryFailure(e.toString()));
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      await deleteNoteUseCase.call(noteId: noteId);

      if (state is DiaryLoaded) {
        final currentNotes = (state as DiaryLoaded).notes;
        final updatedNotes = currentNotes.where((note) => note.id != noteId).toList();
        emit(DiaryLoaded(updatedNotes));
      }
      await fetchNotes();
    } catch (e) {
      emit(DiaryFailure(e.toString()));
    }
  }
}