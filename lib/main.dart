import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/core/app_router.dart';
import 'package:living_diary/presentation/cubit/auth/auth_cubit.dart';
import 'package:living_diary/presentation/cubit/diary/diary_cubit.dart';
import 'package:living_diary/service_locator.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const CupertinoThemeData baseTheme =
    CupertinoThemeData(brightness: Brightness.light);


    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>(),
        ),
        BlocProvider<DiaryCubit>(
          create: (context) => getIt<DiaryCubit>(),
        ),
      ],
      child: CupertinoApp(
        title: 'Living Diary',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          primaryColor: CupertinoColors.activeBlue,
          textTheme: baseTheme.textTheme.copyWith(
            navLargeTitleTextStyle:
            baseTheme.textTheme.navLargeTitleTextStyle.copyWith(
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
        initialRoute: AppRouter.loginRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}