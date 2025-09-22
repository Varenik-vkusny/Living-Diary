// lib/domain/usecases/signup_with_email_usecase.dart

import '../repositories/auth_repository.dart';

class SignUpWithEmailUseCase {
  final AuthRepository repository;

  SignUpWithEmailUseCase(this.repository);


  Future<void> call({required String email, required String password, required String username}) async {
    if (username.isEmpty) throw Exception('Имя пользователя не может быть пустым.');
    // ...
    return await repository.signUpWithEmailAndPassword(email, password, username);
  }
}