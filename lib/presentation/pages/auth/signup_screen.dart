// lib/presentation/pages/auth/signup_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/core/app_router.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../../widgets/auth/cupertino_primary_button.dart';
import '../../widgets/auth/cupertino_text_field_widget.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider УДАЛЕН.
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.diaryListRoute, (route) => false);
        }
        if (state is AuthFailure) {
          showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Ошибка регистрации'),
              content: Text(state.message),
              actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Создать аккаунт')),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text('Присоединяйтесь!', style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('Создайте свой новый аккаунт', style: CupertinoTheme.of(context).textTheme.textStyle!.copyWith(color: CupertinoColors.systemGrey), textAlign: TextAlign.center),
                  const SizedBox(height: 40),
                  CupertinoTextFieldWidget(controller: _usernameController, placeholder: 'Имя пользователя', keyboardType: TextInputType.text, prefixIcon: CupertinoIcons.person_solid),
                  const SizedBox(height: 15),
                  CupertinoTextFieldWidget(controller: _emailController, placeholder: 'Электронная почта', keyboardType: TextInputType.emailAddress, prefixIcon: CupertinoIcons.mail_solid),
                  const SizedBox(height: 15),
                  CupertinoTextFieldWidget(controller: _passwordController, placeholder: 'Пароль', obscureText: true, prefixIcon: CupertinoIcons.lock_fill),
                  const SizedBox(height: 15),
                  CupertinoTextFieldWidget(controller: _confirmPasswordController, placeholder: 'Подтвердите пароль', obscureText: true, prefixIcon: CupertinoIcons.lock_fill),
                  const SizedBox(height: 40),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CupertinoActivityIndicator());
                      }
                      return CupertinoPrimaryButton(
                        text: 'Зарегистрироваться',
                        onPressed: () {
                          context.read<AuthCubit>().signUpWithEmail(
                            username: _usernameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            confirmPassword: _confirmPasswordController.text.trim(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        text: "Уже есть аккаунт? ",
                        style: CupertinoTheme.of(context).textTheme.textStyle!.copyWith(color: CupertinoColors.systemGrey, fontSize: 15),
                        children: const [TextSpan(text: 'Войти', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w600, fontSize: 15))],
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