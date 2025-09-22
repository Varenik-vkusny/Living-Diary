import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:living_diary/presentation/cubit/auth_cubit.dart';
import 'package:living_diary/presentation/cubit/diary/diary_cubit.dart';

// Импорты всех слоев
import 'data/api_client.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/diary_remote_data_source.dart';
import 'data/repository/auth_repository_impl.dart';
import 'data/repository/diary_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/diary_repository.dart';
import 'domain/usecases/diary/create_note_usecase.dart';
import 'domain/usecases/google_sign_in_usecase.dart';
import 'domain/usecases/sign_in_with_email_usecase.dart';
import 'domain/usecases/signup_with_email_usecase.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // --- EXTERNAL ---
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());
  getIt.registerLazySingleton(() => http.Client());

  // --- API CLIENT ---
  getIt.registerLazySingleton(() => ApiClient(getIt(), getIt()));

  // --- DATA SOURCES ---
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      googleSignIn: getIt(),
    ),
  );
  // DiaryRemoteDataSource теперь правильно принимает две зависимости
  getIt.registerLazySingleton<DiaryRemoteDataSource>(
        () => DiaryRemoteDataSourceImpl(getIt(), getIt()),
  );

  // --- REPOSITORIES ---
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(remoteDataSource: getIt()));

  // --- USE CASES ---
  getIt.registerLazySingleton(() => GoogleSignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateNoteUseCase(getIt()));

  // --- CUBITS ---
  getIt.registerFactory(
        () => AuthCubit(
      googleSignInUseCase: getIt(),
      signUpWithEmailUseCase: getIt(),
      signInWithEmailUseCase: getIt(),
    ),
  );
  getIt.registerFactory(() => DiaryCubit(getIt()));
}