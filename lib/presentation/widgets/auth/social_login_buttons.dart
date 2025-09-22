// lib/presentation/auth/widgets/social_login_buttons.dart

import 'package:flutter/cupertino.dart';
// 1. ДОБАВЛЯЕМ ИМПОРТ для SVG
import 'package:flutter_svg/flutter_svg.dart';

// lib/presentation/pages/auth/widgets/social_login_buttons.dart


class SocialLoginButtons extends StatelessWidget {
  // 1. Объявляем финальные переменные для коллбэков.
  // VoidCallback - это просто синоним для Function().
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  // 2. Добавляем их в конструктор как обязательные именованные параметры.
  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          // 3. Используем переданный коллбэк здесь.
          onPressed: onGooglePressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CupertinoColors.systemGrey5),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset('assets/icons/Google__G__logo.svg', height: 30),
            ),
          ),
        ),
        const SizedBox(width: 20),
        CupertinoButton(
          padding: EdgeInsets.zero,
          // 4. И здесь тоже.
          onPressed: onApplePressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CupertinoColors.systemGrey5),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Image.asset('assets/icons/free-apple-logo.png', height: 30, color: CupertinoColors.black),
            ),
          ),
        ),
      ],
    );
  }
}