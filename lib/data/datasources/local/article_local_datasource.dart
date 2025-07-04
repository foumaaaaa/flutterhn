// data/datasources/local/article_local_datasource.dart
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/article_model.dart';

class ArticleLocalDataSource {
  Future<void> insertArticle(ArticleModel article) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'articles',
      article.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertArticles(List<ArticleModel> articles) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();

    for (final article in articles) {
      batch.insert(
        'articles',
        article.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<ArticleModel?> getArticleById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('articles', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return ArticleModel.fromDatabase(maps.first);
    }
    return null;
  }

  Future<List<ArticleModel>> getArticles({
    int? limit,
    int? offset,
    String? orderBy,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'articles',
      orderBy: orderBy ?? 'time DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => ArticleModel.fromDatabase(map)).toList();
  }

  Future<List<ArticleModel>> getFavoriteArticles() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'articles',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'cached_at DESC',
    );

    return maps.map((map) => ArticleModel.fromDatabase(map)).toList();
  }

  Future<void> updateFavoriteStatus(int articleId, bool isFavorite) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'articles',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> deleteOldNonFavoriteArticles() async {
    final db = await DatabaseHelper.instance.database;
    final expirationDate =
        DateTime.now()
            .subtract(const Duration(hours: AppConstants.cacheExpirationHours))
            .toIso8601String();

    await db.delete(
      'articles',
      where: 'is_favorite = ? AND cached_at < ?',
      whereArgs: [0, expirationDate],
    );
  }

  Future<void> deleteArticle(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('articles', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isArticleCached(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'articles',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty;
  }
}
