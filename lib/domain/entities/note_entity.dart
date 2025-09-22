// lib/domain/entities/note_entity.dart
import 'user_entity.dart';

class NoteEntity {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final UserEntity owner;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.owner,
  });
}