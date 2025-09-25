import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:living_diary/presentation/cubit/auth/auth_cubit.dart';
import 'package:living_diary/presentation/cubit/diary/diary_cubit.dart';

import 'data/api_client.dart';
import 'data/datasources/auth/auth_remote_data_source.dart';
import 'data/datasources/diary/diary_remote_data_source.dart';
import 'data/repository/auth/auth_repository_impl.dart';
import 'data/repository/diary/diary_repository_impl.dart';
import 'domain/repositories/auth/auth_repository.dart';
import 'domain/repositories/diary/diary_repository.dart';
import 'domain/usecases/diary/create_note_usecase.dart';
import 'domain/usecases/diary/delete_note_usecase.dart';
import 'domain/usecases/diary/get_notes_usecase.dart';
import 'domain/usecases/diary/update_note_usecase.dart';
import 'domain/usecases/auth/google_sign_in_usecase.dart';
import 'domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'domain/usecases/auth/signup_with_email_usecase.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());
  getIt.registerLazySingleton(() => http.Client());


  getIt.registerLazySingleton(() => ApiClient(getIt(), getIt()));


  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: getIt(),
      googleSignIn: getIt(),
    ),
  );


  getIt.registerLazySingleton<DiaryRemoteDataSource>(
        () => DiaryRemoteDataSourceImpl(getIt()),
  );


  getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(remoteDataSource: getIt()));

  getIt.registerLazySingleton<DiaryRepository>(
          () => DiaryRepositoryImpl(remoteDataSource: getIt()));


  getIt.registerLazySingleton(() => GoogleSignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithEmailUseCase(getIt()));


  getIt.registerFactory(
        () => AuthCubit(
      googleSignInUseCase: getIt(),
      signUpWithEmailUseCase: getIt(),
      signInWithEmailUseCase: getIt(),
    ),
  );
  getIt.registerFactory(() => DiaryCubit(
    createNoteUseCase: getIt(),
    getNotesUseCase: getIt(),
    updateNoteUseCase: getIt(),
    deleteNoteUseCase: getIt(),
  ));  getIt.registerLazySingleton(() => CreateNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => GetNotesUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateNoteUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteNoteUseCase(getIt()));
}