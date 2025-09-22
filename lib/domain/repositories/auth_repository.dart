abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signUpWithEmailAndPassword(String email, String password, String username);
  Future<void> signInWithEmailAndPassword(String email, String password);
  // Методы ниже пока не используем, но пусть будут в контракте для будущего
  Future<void> signInWithPhoneNumber(String phoneNumber);
  Future<void> signOut();
}