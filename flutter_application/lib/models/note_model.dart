import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String? id;
  final String title;
  final String content;
  final DateTime createdAt;
  DateTime? updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
