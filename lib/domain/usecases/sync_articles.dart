// domain/usecases/sync_articles.dart
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class SyncArticles {
  final ArticleRepository repository;

  SyncArticles(this.repository);

  Future<List<Article>> call() async {
    // Sync top stories and return updated list
    final articles = await repository.getTopStories(page: 0, limit: 50);

    // Trigger cleanup of old articles
    await repository.cleanupOldArticles();

    return articles;
  }

  Future<void> callCleanupOnly() async {
    await repository.cleanupOldArticles();
  }
}
