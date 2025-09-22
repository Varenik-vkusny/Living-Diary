// lib/data/models/note_model.dart
import '../../domain/entities/note_entity.dart';
import 'user_model.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required int id,
    required String title,
    required String content,
    required DateTime createdAt,
    required UserModel owner,
  }) : super(id: id, title: title, content: content, createdAt: createdAt, owner: owner);

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],       // <-- Предполагаем, что title и content тоже приходят
      content: json['content'],   // <-- в ответе
      createdAt: DateTime.parse(json['created_at']),
      owner: UserModel.fromJson(json['owner']),
    );
  }
}