// lib/presentation/pages/home/entry_detail_screen.dart

import 'package:flutter/cupertino.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const userEntryText = 'Сегодня был просто замечательный день! Я гулял в парке, слушал пение птиц и ел мороженое. Иногда такие простые вещи приносят больше всего радости. Я почувствовал себя по-настоястоящему счастливым и отдохнувшим.';
    const aiCommentText = 'Здорово, что ты находишь время для таких моментов! Умение ценить простые радости — это важный навык для поддержания ментального баланса. Возможно, тебе стоит сделать такие прогулки регулярной практикой?';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Запись от 19.09.2025'),
      ),
      // Убираем SafeArea отсюда, так как CupertinoPageScaffold уже управляет этим
      child: SingleChildScrollView(
        // Переносим padding внутрь, чтобы он применялся к содержимому, а не к скроллу
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ЗАПИСЬ ПОЛЬЗОВАТЕЛЯ
              const Text(
                'Моя запись:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel),
              ),
              const SizedBox(height: 10),
              Text(
                userEntryText,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 30),

              // БЛОК С КОММЕНТАРИЕМ ОТ ИИ
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
                        // Expanded здесь абсолютно правильное решение и мы его оставляем
                        Expanded(
                          child: Text(
                            'Комментарий от ИИ',
                            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      aiCommentText,
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