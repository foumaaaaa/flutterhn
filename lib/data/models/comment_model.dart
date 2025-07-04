// data/models/comment_model.dart (version mise à jour)
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    super.text,
    super.author,
    required super.time,
    required super.kids,
    super.parent,
    required super.isDeleted,
    required super.isDead,
    required super.level,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, {int level = 0}) {
    return CommentModel(
      id: json['id'] ?? 0,
      text: json['text'],
      author: json['by'],
      time: json['time'] ?? 0,
      kids: List<int>.from(json['kids'] ?? []),
      parent: json['parent'],
      isDeleted: json['deleted'] ?? false,
      isDead: json['dead'] ?? false,
      level: level,
    );
  }

  factory CommentModel.fromDatabase(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      text: map['text'],
      author: map['author'],
      time: map['time'],
      kids: _parseIntList(map['kids']),
      parent: map['parent'],
      isDeleted: map['is_deleted'] == 1,
      isDead: map['is_dead'] == 1,
      level: map['level'],
    );
  }

  /// Nouvelle méthode pour convertir vers le format de votre base de données existante
  Map<String, dynamic> toDatabaseMap(int articleId) {
    return {
      'id': id,
      'text': text,
      'author': author,
      'time': time,
      'kids': kids.join(','),
      'parent': parent,
      'is_deleted': isDeleted ? 1 : 0,
      'is_dead': isDead ? 1 : 0,
      'level': level,
      'article_id': articleId,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  /// Méthode héritée maintenue pour compatibilité
  Map<String, dynamic> toDatabase(int articleId) {
    return toDatabaseMap(articleId);
  }

  static List<int> _parseIntList(String? str) {
    if (str == null || str.isEmpty) return [];
    return str.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }
}
