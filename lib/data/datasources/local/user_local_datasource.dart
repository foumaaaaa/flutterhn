// TODO: Implementer le code pour data/datasources/local/user_local_datasource
// data/datasources/local/user_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../models/user_model.dart';

class UserLocalDataSource {
  Future<void> insertUser(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'users',
      user.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return UserModel.fromDatabase(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('users', orderBy: 'karma DESC');
    return maps.map((map) => UserModel.fromDatabase(map)).toList();
  }

  Future<void> deleteUser(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users');
  }
}
