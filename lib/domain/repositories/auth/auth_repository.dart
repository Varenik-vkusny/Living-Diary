abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signUpWithEmailAndPassword(String email, String password, String username);
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signInWithPhoneNumber(String phoneNumber);
  Future<void> signOut();
}