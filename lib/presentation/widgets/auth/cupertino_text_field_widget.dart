import 'package:flutter/cupertino.dart';

class CupertinoTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const CupertinoTextFieldWidget({
    super.key,
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 0.5,
        ),
      ),
      prefix: prefixIcon != null
          ? Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Icon(
          prefixIcon,
          color: CupertinoColors.systemGrey,
          size: 24,
        ),
      )
          : null,
      style: CupertinoTheme.of(context).textTheme.textStyle,
    );
  }
}