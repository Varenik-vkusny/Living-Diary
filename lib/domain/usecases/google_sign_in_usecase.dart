import '../repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;
  GoogleSignInUseCase(this.repository);

  Future<void> call() {
    return repository.signInWithGoogle();
  }
}