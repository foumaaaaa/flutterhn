// data/datasources/local/comment_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import '../../models/comment_model.dart';
import '../../../core/database/database_helper.dart';
import '../../../domain/entities/comment.dart';

class CommentLocalDataSource {
  static const String tableName = 'comments';

  /// Insérer les commentaires dans la base de données locale
  Future<void> insertComments(List<Comment> comments, int articleId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      // Supprimer les anciens commentaires pour cet article
      batch.delete(tableName, where: 'article_id = ?', whereArgs: [articleId]);

      // Insérer les nouveaux commentaires
      for (final comment in comments) {
        final commentData = {
          'id': comment.id,
          'text': comment.text,
          'author': comment.author,
          'time': comment.time,
          'kids': comment.kids.join(','),
          'parent': comment.parent,
          'is_deleted': comment.isDeleted ? 1 : 0,
          'is_dead': comment.isDead ? 1 : 0,
          'level': comment.level,
          'article_id': articleId,
          'cached_at': DateTime.now().toIso8601String(),
        };

        batch.insert(
          tableName,
          commentData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      print(
        '${comments.length} commentaires sauvegardés localement pour l\'article $articleId',
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
      rethrow;
    }
  }

  /// Récupérer les commentaires pour un article depuis la base locale
  Future<List<CommentModel>> getCommentsForArticle(int articleId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'article_id = ?',
        whereArgs: [articleId],
        orderBy: 'level ASC, time ASC',
      );

      final comments =
          maps.map((map) => CommentModel.fromDatabase(map)).toList();
      print(
        '${comments.length} commentaires récupérés localement pour l\'article $articleId',
      );

      return comments;
    } catch (e) {
      print('Erreur lors de la récupération des commentaires locaux: $e');
      return [];
    }
  }

  /// Récupérer les réponses pour un commentaire spécifique
  Future<List<CommentModel>> getRepliesForComment(int commentId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'parent = ?',
        whereArgs: [commentId],
        orderBy: 'time ASC',
      );

      final replies =
          maps.map((map) => CommentModel.fromDatabase(map)).toList();
      print(
        '${replies.length} réponses récupérées localement pour le commentaire $commentId',
      );

      return replies;
    } catch (e) {
      print('Erreur lors de la récupération des réponses locales: $e');
      return [];
    }
  }

  /// Récupérer un commentaire spécifique par son ID
  Future<CommentModel?> getCommentById(int commentId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [commentId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return CommentModel.fromDatabase(maps.first);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du commentaire $commentId: $e');
      return null;
    }
  }

  /// Supprimer les commentaires pour un article
  Future<void> deleteCommentsForArticle(int articleId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final deletedCount = await db.delete(
        tableName,
        where: 'article_id = ?',
        whereArgs: [articleId],
      );
      print('$deletedCount commentaires supprimés pour l\'article $articleId');
    } catch (e) {
      print('Erreur lors de la suppression des commentaires: $e');
    }
  }

  /// Supprimer les anciens commentaires (plus de 7 jours)
  Future<void> deleteOldComments() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final sevenDaysAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      final deletedCount = await db.delete(
        tableName,
        where: 'cached_at < ?',
        whereArgs: [sevenDaysAgo],
      );
      print('$deletedCount anciens commentaires supprimés');
    } catch (e) {
      print('Erreur lors de la suppression des anciens commentaires: $e');
    }
  }

  /// Vérifier si des commentaires sont en cache pour un article
  Future<bool> hasCommentsForArticle(int articleId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        tableName,
        columns: ['COUNT(*) as count'],
        where: 'article_id = ?',
        whereArgs: [articleId],
      );

      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      print('Erreur lors de la vérification du cache: $e');
      return false;
    }
  }

  /// Parser une liste d'entiers depuis une chaîne
  List<int> _parseIntList(String? str) {
    if (str == null || str.isEmpty) return [];
    return str.split(',').map((e) => int.tryParse(e) ?? 0).toList();
  }
}
