// domain/entities/article.dart
class Article {
  final int id;
  final String? title;
  final String? url;
  final String? text;
  final String? author;
  final int score;
  final int time;
  final List<int> kids;
  final int descendants;
  final String type;
  final bool isDeleted;
  final bool isDead;
  final bool isFavorite;
  final DateTime? cachedAt;

  const Article({
    required this.id,
    this.title,
    this.url,
    this.text,
    this.author,
    required this.score,
    required this.time,
    required this.kids,
    required this.descendants,
    required this.type,
    required this.isDeleted,
    required this.isDead,
    required this.isFavorite,
    this.cachedAt,
  });

  Article copyWith({
    int? id,
    String? title,
    String? url,
    String? text,
    String? author,
    int? score,
    int? time,
    List<int>? kids,
    int? descendants,
    String? type,
    bool? isDeleted,
    bool? isDead,
    bool? isFavorite,
    DateTime? cachedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      text: text ?? this.text,
      author: author ?? this.author,
      score: score ?? this.score,
      time: time ?? this.time,
      kids: kids ?? this.kids,
      descendants: descendants ?? this.descendants,
      type: type ?? this.type,
      isDeleted: isDeleted ?? this.isDeleted,
      isDead: isDead ?? this.isDead,
      isFavorite: isFavorite ?? this.isFavorite,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  DateTime get publishedDate =>
      DateTime.fromMillisecondsSinceEpoch(time * 1000);

  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasComments => kids.isNotEmpty;
}
