// lib/data/models/note_model.dart

import 'package:living_diary/data/models/auth/user_model.dart';

import '../../../domain/entities/diary/note_entity.dart';
import '../../../domain/entities/auth/user_entity.dart';
class NoteModel extends NoteEntity {
  NoteModel({
    int? id,
    required String title,
    required String content,
    DateTime? createdAt,
    UserEntity? owner,
    String? comment,
  }) : super(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt,
    owner: owner,
    comment: comment,
  );

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      owner: json['owner'] != null
          ? UserModel.fromJson(json['owner'])
          : null,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'title': title,
      'content': content,
    };
  }
}