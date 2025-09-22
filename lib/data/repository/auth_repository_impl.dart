import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password, String username) {
    return remoteDataSource.signUpWithEmailAndPassword(email, password, username);
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return remoteDataSource.signInWithEmailAndPassword(email, password);
  }


  // Заглушки для методов, которые мы пока не реализуем
  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) {
    throw UnimplementedError('Вход по номеру телефона еще не реализован');
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError('Выход из системы еще не реализован');
  }
}