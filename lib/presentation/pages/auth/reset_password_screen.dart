

import 'package:flutter/cupertino.dart';
import '../../widgets/auth/cupertino_primary_button.dart';
import '../../widgets/auth/cupertino_text_field_widget.dart';


class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Сброс пароля"),
      ),
      child: SafeArea(
        // Оборачиваем в SingleChildScrollView для прокрутки
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Добавим отступ, чтобы контент был по центру
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                CupertinoTextFieldWidget(
                  controller: emailController,
                  placeholder: "Введите почту",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: CupertinoIcons.mail_solid,
                ),
                const SizedBox(height: 20),
                CupertinoPrimaryButton(
                  onPressed: () {},
                  text: "Отправить еще раз",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}