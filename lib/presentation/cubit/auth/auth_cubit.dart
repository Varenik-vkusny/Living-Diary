// lib/presentation/pages/auth/cubit/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_diary/domain/usecases/auth/google_sign_in_usecase.dart';
import 'package:living_diary/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:living_diary/domain/usecases/auth/signup_with_email_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;

  AuthCubit({
    required GoogleSignInUseCase googleSignInUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
  })  : _googleSignInUseCase = googleSignInUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase,
        _signInWithEmailUseCase = signInWithEmailUseCase,
        super(AuthInitial());

  // ВХОД ЧЕРЕЗ GOOGLE
  void signInWithGoogle() async {
    print("--- CUBIT: signInWithGoogle вызван! ---");
    emit(AuthLoading());
    try {
      await _googleSignInUseCase.call();
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // РЕГИСТРАЦИЯ ПО EMAIL
  void signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
  }) async {
    print("--- CUBIT: signUpWithEmail вызван! ---");
    if (password != confirmPassword) {
      emit(AuthFailure('Пароли не совпадают'));
      return;
    }
    emit(AuthLoading());
    try {
      await _signUpWithEmailUseCase.call(email: email, password: password, username: username);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


  // ВХОД ПО EMAIL
  void signInWithEmail({required String email, required String password}) async {
    print("--- CUBIT: signInWithEmail вызван! ---");
    emit(AuthLoading());
    try {
      await _signInWithEmailUseCase.call(email: email, password: password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}