// lib/presentation/pages/home/diary_list_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:living_diary/core/app_router.dart';
// Убедись, что у тебя созданы эти два файла-сущности в domain/entities
import 'package:living_diary/domain/entities/note_entity.dart';
import 'package:living_diary/domain/entities/user_entity.dart';

// 1. Превращаем виджет в StatefulWidget, чтобы он мог хранить и изменять состояние (список заметок)
class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  // 2. Локальный список для хранения наших заметок
  final List<NoteEntity> _notes = [];

  // Метод для перехода на экран создания заметки
  void _navigateToCreateNote() async {
    // 3. Переходим на новый экран и ждем, пока он закроется
    final result = await Navigator.of(context).pushNamed(AppRouter.newEntryRoute);

    // 4. Проверяем результат. Мы договорились, что NewEntryScreen вернет 'true' при успехе.
    if (result == true) {
      // Когда бэкенд заработает, здесь будет вызов `diaryCubit.fetchNotes()`
      // А пока что мы просто добавляем фейковую заметку в список, чтобы увидеть изменения
      setState(() {
        _notes.insert(0, NoteEntity(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'Новая заметка от ${DateTime.now().hour}:${DateTime.now().minute}',
          content: 'Это содержимое новой заметки, созданной локально.',
          createdAt: DateTime.now(),
          // Фейковый владелец
          owner: UserEntity(id: 1, username: 'Test User', email: 'test@user.com'),
        ));
      });
    }
  }

  // Метод для удаления заметки
  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Мой дневник'),
        // TODO: В будущем здесь можно добавить иконку профиля
        // leading: CupertinoButton(...)
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _navigateToCreateNote,
        ),
      ),
      // 5. Проверяем, пуст ли список заметок
      child: _notes.isEmpty
          ? const Center(
        // 6. Если список пуст, показываем красивую заглушку
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.moon_zzz, size: 60, color: CupertinoColors.systemGrey2),
              SizedBox(height: 16),
              Text(
                'Ваш дневник пока пуст',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Нажмите на "+" вверху, чтобы добавить свою первую запись и начать рефлексию.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
              ),
            ],
          ),
        ),
      )
      // 7. Если в списке есть заметки, строим ListView.builder
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          // 8. Оборачиваем элемент списка в Dismissible для удаления свайпом
          return Dismissible(
            key: Key(note.id.toString()), // Уникальный ключ для каждого элемента
            direction: DismissDirection.endToStart, // Свайп только справа налево
            onDismissed: (direction) {
              _deleteNote(index); // Вызываем наш метод удаления
            },
            background: Container(
              color: CupertinoColors.destructiveRed,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(CupertinoIcons.delete, color: CupertinoColors.white),
            ),
            child: CupertinoListTile(
              title: Text(note.title),
              subtitle: Text('Создано: ${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year}'),
              leading: const Icon(CupertinoIcons.doc_text_fill),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                // TODO: Реализовать переход на EntryDetailScreen,
                // передав в него 'note' для отображения
                // Navigator.of(context).pushNamed(AppRouter.entryDetailRoute, arguments: note);
              },
            ),
          );
        },
      ),
    );
  }
}