// TODO: Implementer le code pour core/constants/app_constants
// core/constants/app_constants.dart
class AppConstants {
  static const int cacheExpirationHours = 24;
  static const int maxCachedArticles = 1000;
  static const int articlesPerPage = 20;
  static const int maxCommentDepth = 10;
  static const int cleanupIntervalHours = 6;

  // Story types
  static const String storyType = 'story';
  static const String commentType = 'comment';
  static const String jobType = 'job';
  static const String pollType = 'poll';
  static const String pollOptType = 'pollopt';
}
