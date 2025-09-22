// lib/presentation/pages/home/new_entry_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/diary/diary_cubit.dart';
import '../../cubit/diary/diary_state.dart';


class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});
  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider УДАЛЕН.
    return BlocListener<DiaryCubit, DiaryState>(
      listener: (context, state) {
        if (state is DiaryCreationSuccess) {
          Navigator.of(context).pop(true);
        }
        if (state is DiaryError) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Ошибка'),
              content: Text(state.message),
              actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Новая запись'),
          trailing: BlocBuilder<DiaryCubit, DiaryState>(
            builder: (context, state) {
              final bool isLoading = state is DiaryLoading;
              return CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: isLoading ? null : () {
                  context.read<DiaryCubit>().createNote(
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                  );
                },
                child: const Text('Сохранить'),
              );
            },
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Заголовок',
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 22),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4))),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: CupertinoTextField(
                    controller: _contentController,
                    placeholder: 'Что у тебя на уме?',
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 18),
                    decoration: const BoxDecoration(),
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