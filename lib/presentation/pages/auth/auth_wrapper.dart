// lib/presentation/pages/auth/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:living_diary/presentation/pages/auth/login_screen.dart';
import 'package:living_diary/presentation/pages/home/diary_list_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Пока ждем ответа от Firebase, показываем загрузку
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        // Если есть данные о пользователе, значит он вошел
        if (snapshot.hasData) {
          return const DiaryListScreen();
        }

        // Если данных нет, показываем экран входа
        return const LoginScreen();
      },
    );
  }
}