// lib/data/repository/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/repositories/auth/auth_repository.dart';
import '../../datasources/auth/auth_remote_data_source.dart';

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

  @override
  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) {
    throw UnimplementedError('Вход по номеру телефона еще не реализован');
  }
}