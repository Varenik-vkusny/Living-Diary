// lib/presentation/auth/widgets/social_login_buttons.dart

import 'package:flutter/cupertino.dart';

import 'package:flutter_svg/flutter_svg.dart';




class SocialLoginButtons extends StatelessWidget {


  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;


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