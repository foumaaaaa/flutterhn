// TODO: Implementer le code pour domain/repositories/user_repository
// domain/repositories/user_repository.dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<List<User>> getUsersByIds(List<String> ids);
}
