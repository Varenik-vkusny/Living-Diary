// lib/presentation/auth/forgot_password_screen.dart

import 'package:flutter/cupertino.dart';

import '../../widgets/auth/cupertino_primary_button.dart';
import '../../widgets/auth/cupertino_text_field_widget.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    final email = _emailController.text;
    print('Попытка сброса пароля для: $email');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Забыли пароль'),
      ),
      child: SafeArea(
        // Оборачиваем в SingleChildScrollView для прокрутки
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40), // Отступ сверху
                Text(
                  'Сброс пароля',
                  style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Введите вашу почту, чтобы получить ссылку для сброса пароля.',
                  style: CupertinoTheme.of(context).textTheme.textStyle!.copyWith(
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CupertinoTextFieldWidget(
                  controller: _emailController,
                  placeholder: 'Электронная почта',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail_solid,
                ),
                const SizedBox(height: 40),
                CupertinoPrimaryButton(
                  text: 'Отправить ссылку',
                  onPressed: _resetPassword,
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Вернуться ко входу',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Отступ снизу
              ],
            ),
          ),
        ),
      ),
    );
  }
}