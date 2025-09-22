// lib/core/app_router.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/service_locator.dart';

// Импорты экранов
import 'package:living_diary/presentation/pages/auth/auth_wrapper.dart';
import 'package:living_diary/presentation/pages/auth/login_screen.dart';
import 'package:living_diary/presentation/pages/auth/signup_screen.dart';
import 'package:living_diary/presentation/pages/home/diary_list_screen.dart';
import 'package:living_diary/presentation/pages/home/new_entry_screen.dart';
import 'package:living_diary/presentation/pages/home/entry_detail_screen.dart';
import 'package:living_diary/presentation/pages/auth/forgot_password_screen.dart';


// Импорты кубитов


import '../presentation/cubit/auth_cubit.dart';
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
      case newEntryRoute:
      // ГЛАВНОЕ ИСПРАВЛЕНИЕ: Предоставляем DiaryCubit экрану
        return CupertinoPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<DiaryCubit>(),
            child: const NewEntryScreen(),
          ),
        );
      case entryDetailRoute:
        return CupertinoPageRoute(builder: (_) => const EntryDetailScreen());
      default:
        return CupertinoPageRoute(
          builder: (_) => const CupertinoPageScaffold(
            child: Center(child: Text('Ошибка: Страница не найдена')),
          ),
        );
    }
  }
}