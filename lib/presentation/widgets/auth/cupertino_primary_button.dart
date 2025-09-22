import 'package:flutter/cupertino.dart';

class CupertinoPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CupertinoPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = CupertinoColors.activeBlue,
    this.textColor = CupertinoColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      borderRadius: BorderRadius.circular(10.0),
      child: Text(
        text,
        style: CupertinoTheme.of(context).textTheme.navTitleTextStyle!.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}