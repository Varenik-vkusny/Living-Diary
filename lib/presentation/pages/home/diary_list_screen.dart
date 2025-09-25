import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:living_diary/core/app_router.dart';
import 'package:living_diary/domain/entities/diary/note_entity.dart';
import 'package:living_diary/presentation/cubit/diary/diary_cubit.dart';
import 'package:living_diary/presentation/cubit/diary/diary_state.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  @override
  void initState() {
    super.initState();
    // Запрашиваем список заметок при первом открытии экрана.
    context.read<DiaryCubit>().fetchNotes();
  }

  void _navigateToCreateOrEdit([NoteEntity? note]) async {
    // Передаем заметку, если она есть (для редактирования), или null (для создания)
    final result =
    await Navigator.of(context).pushNamed(AppRouter.newEntryRoute, arguments: note);

    // Если экран вернул 'true', значит, данные изменились, и нужно обновить список
    if (result == true) {
      context.read<DiaryCubit>().fetchNotes();
    }
  }

  String _formatNoteDate(DateTime? date) {
    if (date == null) return 'Дата неизвестна';
    // Преобразуем в локальное время
    return DateFormat('dd.MM.yyyy, HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Мой дневник'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _navigateToCreateOrEdit(null),
        ),
      ),
      child: BlocBuilder<DiaryCubit, DiaryState>(
        builder: (context, state) {
          if (state is DiaryLoading || state is DiaryInitial) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is DiaryLoaded) {
            final notes = state.notes;
            if (notes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.moon_zzz, size: 60, color: CupertinoColors.systemGrey2),
                      SizedBox(height: 16),
                      Text('Ваш дневник пока пуст', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Нажмите на "+" вверху, чтобы добавить свою первую запись.', textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16)),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: Key(note.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context.read<DiaryCubit>().deleteNote(note.id!);
                  },
                  background: Container(
                    color: CupertinoColors.destructiveRed,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
                  ),
                  // Оборачиваем ListTile в GestureDetector для обработки нажатий
                  child: GestureDetector(
                    onTap: () {
                      // При коротком тапе открываем экран деталей
                      Navigator.of(context).pushNamed(AppRouter.entryDetailRoute, arguments: note);
                    },
                    onLongPress: () {
                      // При долгом нажатии открываем экран редактирования
                      _navigateToCreateOrEdit(note);
                    },
                    child: CupertinoListTile(
                      title: Text(note.title),

                      subtitle: Text('Создано: ${_formatNoteDate(note.createdAt)}'),
                      leading: const Icon(CupertinoIcons.doc_text_fill),
                      trailing: const Icon(CupertinoIcons.right_chevron),
                    ),
                  ),
                );
              },
            );
          }

          if (state is DiaryFailure) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }

          return const Center(child: Text('Неизвестное состояние'));
        },
      ),
    );
  }
}