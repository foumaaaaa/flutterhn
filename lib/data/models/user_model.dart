// TODO: Implementer le code pour data/models/user_model
// data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.created,
    required super.karma,
    super.about,
    required super.submitted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      created: json['created'] ?? 0,
      karma: json['karma'] ?? 0,
      about: json['about'],
      submitted: List<int>.from(json['submitted'] ?? []),
    );
  }

  factory UserModel.fromDatabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      created: map['created'],
      karma: map['karma'],
      about: map['about'],
      submitted: _parseIntList(map['submitted']),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'created': created,
      'karma': karma,
      'about': about,
      'submitted': submitted.join(','),
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  static List<int> _parseIntList(String? str) {
    if (str == null || str.isEmpty) return [];
    return str.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }
}
