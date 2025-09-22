import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:living_diary/core/app_router.dart';
import 'package:living_diary/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const CupertinoThemeData baseTheme = CupertinoThemeData(brightness: Brightness.light);

    return CupertinoApp(
      title: 'Living Diary',
      debugShowCheckedModeBanner: false, // Убираем баннер DEBUG
      theme: baseTheme.copyWith(
        primaryColor: CupertinoColors.activeBlue,
        textTheme: baseTheme.textTheme.copyWith(
          navLargeTitleTextStyle: baseTheme.textTheme.navLargeTitleTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
            fontSize: 34.0,
          ),
          navTitleTextStyle: baseTheme.textTheme.navTitleTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
            fontSize: 17.0,
          ),
          textStyle: baseTheme.textTheme.textStyle.copyWith(
            color: CupertinoColors.black,
            fontSize: 17.0,
          ),
        ),
      ),
      // Указываем AppRouter'у, с какого маршрута начинать
      initialRoute: AppRouter.loginRoute,
      // Говорим, что AppRouter отвечает за создание всех маршрутов
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}