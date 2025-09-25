// lib/presentation/pages/auth/login_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/core/app_router.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../widgets/auth/cupertino_primary_button.dart';
import '../../widgets/auth/cupertino_text_field_widget.dart';
import '../../widgets/auth/social_login_buttons.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppRouter предоставляет Cubit, поэтому здесь только слушаем и строим UI
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Заменяем весь стек экранов на главный экран
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.diaryListRoute, (route) => false);
        }
        if (state is AuthFailure) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Ошибка входа'),
              content: Text(state.message),
              actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text('С возвращением!', style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(fontSize: 30.0), textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('Войдите, чтобы продолжить', style: CupertinoTheme.of(context).textTheme.textStyle!.copyWith(color: CupertinoColors.systemGrey), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  CupertinoTextFieldWidget(controller: _emailController, placeholder: 'Электронная почта', keyboardType: TextInputType.emailAddress, prefixIcon: CupertinoIcons.mail_solid),
                  const SizedBox(height: 15),
                  CupertinoTextFieldWidget(controller: _passwordController, placeholder: 'Пароль', obscureText: true, prefixIcon: CupertinoIcons.lock_fill),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pushNamed(AppRouter.forgotPasswordRoute),
                      child: const Text('Забыли пароль?', style: TextStyle(color: CupertinoColors.activeBlue)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ИСПРАВЛЕННЫЙ БЛОК
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CupertinoPrimaryButton(
                            text: 'Войти',
                            // Если идет загрузка, передаем пустую функцию.
                            // В самом виджете кнопки мы можем сделать ее неактивной.
                            // Но для простоты можно оставить так, BlocListener все равно
                            // не даст нажать ее дважды.
                            onPressed: isLoading ? () {} : () {
                              context.read<AuthCubit>().signInWithEmail(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          const Text('Или войдите с помощью', textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.systemGrey)),
                          const SizedBox(height: 20),

                          // Если идет загрузка, показываем индикатор, иначе - кнопки
                          isLoading
                              ? const Center(child: CupertinoActivityIndicator(radius: 20))
                              : SocialLoginButtons(
                            onGooglePressed: () => context.read<AuthCubit>().signInWithGoogle(),
                            onApplePressed: () {},
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRouter.signupRoute),
                    child: RichText(
                      text: TextSpan(
                        text: "Нет аккаунта? ",
                        style: CupertinoTheme.of(context).textTheme.textStyle!.copyWith(color: CupertinoColors.systemGrey, fontSize: 15),
                        children: const [
                          TextSpan(text: 'Регистрация', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}