// lib/presentation/pages/home/new_entry_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/domain/entities/diary/note_entity.dart';
import '../../cubit/diary/diary_cubit.dart';
import '../../cubit/diary/diary_state.dart';

class NewEntryScreen extends StatefulWidget {
  // Поле для принимаемой заметки. Если оно null - значит, мы создаем новую.
  final NoteEntity? noteToEdit;

  const NewEntryScreen({super.key, this.noteToEdit});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Если нам передали заметку для редактирования...
    if (widget.noteToEdit != null) {
      // ...то заполняем поля ее данными.
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
    }
    _titleController.addListener(_validateFields);
    _contentController.addListener(_validateFields);
    _validateFields(); // Проверяем поля при инициализации
  }

  void _validateFields() {
    final bool isEnabled = _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty;
    if (_isSaveButtonEnabled != isEnabled) {
      setState(() {
        _isSaveButtonEnabled = isEnabled;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveOrUpdateNote() {
    if (!_isSaveButtonEnabled) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Если мы редактируем существующую заметку...
    if (widget.noteToEdit != null) {
      // ...вызываем метод updateNote
      context.read<DiaryCubit>().updateNote(
        widget.noteToEdit!.id!,
        title: title,
        content: content,
      );
    } else {
      // ...иначе, создаем новую
      context.read<DiaryCubit>().createNote(title, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Определяем, в каком мы режиме, чтобы менять заголовок
    final isEditing = widget.noteToEdit != null;

    return BlocListener<DiaryCubit, DiaryState>(
      listener: (context, state) {
        if (state is DiarySuccess) {
          Navigator.of(context).pop(true); // Возвращаем true в обоих случаях
        }
        if (state is DiaryFailure) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Ошибка'),
              content: Text(state.message),
              actions: [
                CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(isEditing ? 'Редактирование' : 'Новая запись'),
          trailing: BlocBuilder<DiaryCubit, DiaryState>(
            builder: (context, state) {
              if (state is DiaryLoading) {
                return const CupertinoActivityIndicator();
              }
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isSaveButtonEnabled ? _saveOrUpdateNote : null,
                child: const Text('Сохранить'),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Padding(
            // ... остальной UI без изменений ...
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Заголовок',
                  // ...
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: CupertinoTextField(
                    controller: _contentController,
                    placeholder: 'Что у тебя на уме?',
                    // ...
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}