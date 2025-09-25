// lib/core/app_router.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/domain/entities/diary/note_entity.dart';
import 'package:living_diary/service_locator.dart';
import 'package:living_diary/presentation/pages/auth/auth_wrapper.dart';
import 'package:living_diary/presentation/pages/auth/signup_screen.dart';
import 'package:living_diary/presentation/pages/home/diary_list_screen.dart';
import 'package:living_diary/presentation/pages/home/new_entry_screen.dart';
import 'package:living_diary/presentation/pages/home/entry_detail_screen.dart';
import 'package:living_diary/presentation/pages/auth/forgot_password_screen.dart';
import '../presentation/cubit/auth/auth_cubit.dart';
import '../presentation/cubit/diary/diary_cubit.dart';

class AppRouter {
  static const String loginRoute = '/';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot_password';
  static const String diaryListRoute = '/diary';
  static const String entryDetailRoute = '/diary/entry';
  static const String newEntryRoute = '/diary/new';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const AuthWrapper(),
          ),
        );
      case signupRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const SignupScreen(),
          ),
        );
      case forgotPasswordRoute:
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordScreen());
      case diaryListRoute:
        return CupertinoPageRoute(builder: (_) => const DiaryListScreen());

    // ИЗМЕНЕНИЕ: Экран создания/редактирования
      case newEntryRoute:
      // Аргумент теперь необязательный. Если его нет, noteToEdit будет null (создание новой)
        final noteToEdit = settings.arguments as NoteEntity?;
        return CupertinoPageRoute(
          builder: (_) => NewEntryScreen(noteToEdit: noteToEdit),
        );

    // ИЗМЕНЕНИЕ: Экран просмотра деталей
      case entryDetailRoute:
      // Аргумент обязательный. Мы должны передать заметку для просмотра
        final note = settings.arguments as NoteEntity;
        return CupertinoPageRoute(
          builder: (_) => EntryDetailScreen(note: note),
        );

      default:
        return CupertinoPageRoute(
          builder: (_) => const CupertinoPageScaffold(
            child: Center(child: Text('Ошибка: Страница не найдена')),
          ),
        );
    }
  }
}