// TODO: Implementer le code pour data/models/article_model
// data/models/article_model.dart
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    super.title,
    super.url,
    super.text,
    super.author,
    required super.score,
    required super.time,
    required super.kids,
    required super.descendants,
    required super.type,
    required super.isDeleted,
    required super.isDead,
    required super.isFavorite,
    super.cachedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'],
      url: json['url'],
      text: json['text'],
      author: json['by'],
      score: json['score'] ?? 0,
      time: json['time'] ?? 0,
      kids: List<int>.from(json['kids'] ?? []),
      descendants: json['descendants'] ?? 0,
      type: json['type'] ?? 'story',
      isDeleted: json['deleted'] ?? false,
      isDead: json['dead'] ?? false,
      isFavorite: false, // Will be set from local database
    );
  }

  factory ArticleModel.fromDatabase(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      text: map['text'],
      author: map['author'],
      score: map['score'],
      time: map['time'],
      kids: _parseIntList(map['kids']),
      descendants: map['descendants'],
      type: map['type'],
      isDeleted: map['is_deleted'] == 1,
      isDead: map['is_dead'] == 1,
      isFavorite: map['is_favorite'] == 1,
      cachedAt:
          map['cached_at'] != null ? DateTime.parse(map['cached_at']) : null,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'text': text,
      'author': author,
      'score': score,
      'time': time,
      'kids': kids.join(','),
      'descendants': descendants,
      'type': type,
      'is_deleted': isDeleted ? 1 : 0,
      'is_dead': isDead ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  static List<int> _parseIntList(String? str) {
    if (str == null || str.isEmpty) return [];
    return str.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }

  ArticleModel copyWithFavorite(bool isFavorite) {
    return ArticleModel(
      id: id,
      title: title,
      url: url,
      text: text,
      author: author,
      score: score,
      time: time,
      kids: kids,
      descendants: descendants,
      type: type,
      isDeleted: isDeleted,
      isDead: isDead,
      isFavorite: isFavorite,
      cachedAt: cachedAt,
    );
  }
}
