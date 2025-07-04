// TODO: Implementer le code pour domain/entities/comment
// domain/entities/comment.dart
class Comment {
  final int id;
  final String? text;
  final String? author;
  final int time;
  final List<int> kids;
  final int? parent;
  final bool isDeleted;
  final bool isDead;
  final int level;

  const Comment({
    required this.id,
    this.text,
    this.author,
    required this.time,
    required this.kids,
    this.parent,
    required this.isDeleted,
    required this.isDead,
    required this.level,
  });

  Comment copyWith({
    int? id,
    String? text,
    String? author,
    int? time,
    List<int>? kids,
    int? parent,
    bool? isDeleted,
    bool? isDead,
    int? level,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      time: time ?? this.time,
      kids: kids ?? this.kids,
      parent: parent ?? this.parent,
      isDeleted: isDeleted ?? this.isDeleted,
      isDead: isDead ?? this.isDead,
      level: level ?? this.level,
    );
  }

  DateTime get publishedDate =>
      DateTime.fromMillisecondsSinceEpoch(time * 1000);
  bool get hasReplies => kids.isNotEmpty;
  bool get isVisible => !isDeleted && !isDead && text != null;
}
