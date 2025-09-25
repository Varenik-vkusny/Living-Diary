// lib/domain/entities/note_entity.dart
import '../auth/user_entity.dart';

class NoteEntity {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final UserEntity? owner;
  final String? comment;

  NoteEntity({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.owner,
    this.comment,
  });
}