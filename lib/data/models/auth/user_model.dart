// lib/data/models/user_model.dart
import '../../../domain/entities/auth/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.username, required super.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}