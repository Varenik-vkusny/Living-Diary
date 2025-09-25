// lib/presentation/pages/home/entry_detail_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:living_diary/domain/entities/diary/note_entity.dart';

class EntryDetailScreen extends StatelessWidget {
  final NoteEntity note;

  const EntryDetailScreen({super.key, required this.note});

  String _formatNoteDate(DateTime? date) {
    if (date == null) return 'Дата неизвестна';
    return DateFormat('dd.MM.yyyy, HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Запись от ${_formatNoteDate(note.createdAt)}'),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Отображаем реальный заголовок заметки
              Text(
                note.title,
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 20),
              const Text(
                'Моя запись:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(height: 10),
              // Отображаем реальный текст заметки
              Text(
                note.content,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 30),



              if (note.comment != null && note.comment!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(CupertinoIcons.sparkles, color: CupertinoColors.activeBlue, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Комментарий от ИИ',
                            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        note.comment!,
                        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          fontStyle: FontStyle.italic,
                          color: CupertinoColors.secondaryLabel,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}