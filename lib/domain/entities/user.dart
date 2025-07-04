// TODO: Implementer le code pour domain/entities/user
// domain/entities/user.dart
class User {
  final String id;
  final int created;
  final int karma;
  final String? about;
  final List<int> submitted;

  const User({
    required this.id,
    required this.created,
    required this.karma,
    this.about,
    required this.submitted,
  });

  User copyWith({
    String? id,
    int? created,
    int? karma,
    String? about,
    List<int>? submitted,
  }) {
    return User(
      id: id ?? this.id,
      created: created ?? this.created,
      karma: karma ?? this.karma,
      about: about ?? this.about,
      submitted: submitted ?? this.submitted,
    );
  }

  DateTime get createdDate =>
      DateTime.fromMillisecondsSinceEpoch(created * 1000);
}
