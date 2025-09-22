import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/diary/create_note_usecase.dart';
import 'diary_state.dart';


class DiaryCubit extends Cubit<DiaryState> {
  final CreateNoteUseCase _createNoteUseCase;

  DiaryCubit(this._createNoteUseCase) : super(DiaryInitial());

  void createNote({required String title, required String content}) async {
    emit(DiaryLoading());
    try {
      await _createNoteUseCase.call(title: title, content: content);
      emit(DiaryCreationSuccess());
    } catch (e) {
      emit(DiaryError(e.toString()));
    }
  }
}