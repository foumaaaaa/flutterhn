// TODO: Implementer le code pour services/cache_service
// services/cache_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/article.dart';
import '../data/models/article_model.dart';

class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimestampPrefix = 'cache_ts_';
  static const Duration _defaultCacheExpiration = Duration(hours: 24);

  static Future<void> cacheArticleList(
    String key,
    List<Article> articles,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articlesJson =
          articles.map((article) {
            if (article is ArticleModel) {
              return article.toDatabase();
            }
            return _articleToMap(article);
          }).toList();

      await prefs.setString('$_cachePrefix$key', json.encode(articlesJson));
      await prefs.setInt(
        '$_cacheTimestampPrefix$key',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Failed to cache article list: $e');
    }
  }

  static Future<List<Article>?> getCachedArticleList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cachePrefix$key');
      final timestamp = prefs.getInt('$_cacheTimestampPrefix$key');

      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _defaultCacheExpiration) {
        await _removeCachedData(key);
        return null;
      }

      final List<dynamic> articlesJson = json.decode(cachedData);
      return articlesJson
          .map((json) => ArticleModel.fromDatabase(json))
          .toList();
    } catch (e) {
      print('Failed to get cached article list: $e');
      return null;
    }
  }

  static Future<void> cacheData<T>(
    String key,
    T data, {
    Duration? expiration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$key', json.encode(data));
      await prefs.setInt(
        '$_cacheTimestampPrefix$key',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Failed to cache data: $e');
    }
  }

  static Future<T?> getCachedData<T>(String key, {Duration? expiration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cachePrefix$key');
      final timestamp = prefs.getInt('$_cacheTimestampPrefix$key');

      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expirationDuration = expiration ?? _defaultCacheExpiration;

      if (DateTime.now().difference(cacheTime) > expirationDuration) {
        await _removeCachedData(key);
        return null;
      }

      return json.decode(cachedData) as T;
    } catch (e) {
      print('Failed to get cached data: $e');
      return null;
    }
  }

  static Future<void> removeCachedData(String key) async {
    await _removeCachedData(key);
  }

  static Future<void> _removeCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheTimestampPrefix$key');
    } catch (e) {
      print('Failed to remove cached data: $e');
    }
  }

  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) ||
            key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Failed to clear all cache: $e');
    }
  }

  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
          }
        }
      }

      return totalSize;
    } catch (e) {
      print('Failed to calculate cache size: $e');
      return 0;
    }
  }

  static Map<String, dynamic> _articleToMap(Article article) {
    return {
      'id': article.id,
      'title': article.title,
      'url': article.url,
      'text': article.text,
      'author': article.author,
      'score': article.score,
      'time': article.time,
      'kids': article.kids.join(','),
      'descendants': article.descendants,
      'type': article.type,
      'is_deleted': article.isDeleted ? 1 : 0,
      'is_dead': article.isDead ? 1 : 0,
      'is_favorite': article.isFavorite ? 1 : 0,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }
}
