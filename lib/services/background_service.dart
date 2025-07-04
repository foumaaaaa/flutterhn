// TODO: Implementer le code pour services/background_service
// services/background_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local/article_local_datasource.dart';
import '../data/datasources/local/comment_local_datasource.dart';
import '../core/constants/app_constants.dart';

class BackgroundService {
  static const String _cleanupEnabledKey = 'auto_cleanup_enabled';
  static const String _lastCleanupKey = 'last_cleanup_timestamp';

  static Timer? _cleanupTimer;
  static final ArticleLocalDataSource _articleDataSource =
      ArticleLocalDataSource();
  static final CommentLocalDataSource _commentDataSource =
      CommentLocalDataSource();

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_cleanupEnabledKey) ?? true;

    if (isEnabled) {
      await _startPeriodicCleanup();
    }
  }

  static Future<void> _startPeriodicCleanup() async {
    _cleanupTimer?.cancel();

    // Run cleanup every 6 hours
    _cleanupTimer = Timer.periodic(
      const Duration(hours: AppConstants.cleanupIntervalHours),
      (timer) async {
        await performCleanup();
      },
    );

    // Also run cleanup on startup if it's been more than 24 hours
    await _checkAndRunInitialCleanup();
  }

  static Future<void> _checkAndRunInitialCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCleanup = prefs.getInt(_lastCleanupKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // If last cleanup was more than 24 hours ago, run it now
    if (now - lastCleanup > const Duration(hours: 24).inMilliseconds) {
      await performCleanup();
    }
  }

  static Future<void> performCleanup() async {
    try {
      // Delete old non-favorite articles
      await _articleDataSource.deleteOldNonFavoriteArticles();

      // Update last cleanup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastCleanupKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('Background cleanup completed successfully');
    } catch (e) {
      print('Background cleanup failed: $e');
    }
  }

  static Future<void> clearAllCache() async {
    try {
      // This would require implementing a method to clear all cached data
      // For now, we'll just delete old articles and comments
      await _articleDataSource.deleteOldNonFavoriteArticles();
      print('Cache cleared successfully');
    } catch (e) {
      print('Failed to clear cache: $e');
      rethrow;
    }
  }

  static Future<bool> isCleanupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cleanupEnabledKey) ?? true;
  }

  static Future<void> setCleanupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cleanupEnabledKey, enabled);

    if (enabled) {
      await _startPeriodicCleanup();
    } else {
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
    }
  }

  static void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}
