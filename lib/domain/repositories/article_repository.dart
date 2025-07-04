// TODO: Implementer le code pour domain/repositories/article_repository
// domain/repositories/article_repository.dart
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getTopStories({int page = 0, int limit = 20});
  Future<List<Article>> getNewStories();
  Future<List<Article>> getAskStories();
  Future<List<Article>> getShowStories();
  Future<List<Article>> getJobStories();
  Future<Article?> getArticleById(int id);
  Future<List<Article>> getFavoriteArticles();
  Future<void> addToFavorites(int articleId);
  Future<void> removeFromFavorites(int articleId);
  Future<void> cleanupOldArticles();
}
