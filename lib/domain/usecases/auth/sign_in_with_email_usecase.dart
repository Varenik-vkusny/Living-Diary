// lib/domain/usecases/sign_in_with_email_usecase.dart

import '../../repositories/auth/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository repository;
  SignInWithEmailUseCase(this.repository);

  Future<void> call({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email и пароль не могут быть пустыми.');
    }
    return await repository.signInWithEmailAndPassword(email, password);
  }
}