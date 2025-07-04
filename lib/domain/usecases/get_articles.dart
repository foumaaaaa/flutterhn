// TODO: Implementer le code pour domain/usecases/get_articles
// domain/usecases/get_articles.dart
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticles {
  final ArticleRepository repository;

  GetArticles(this.repository);

  Future<List<Article>> callTopStories({int page = 0, int limit = 20}) async {
    return await repository.getTopStories(page: page, limit: limit);
  }

  Future<List<Article>> callNewStories() async {
    return await repository.getNewStories();
  }

  Future<List<Article>> callAskStories() async {
    return await repository.getAskStories();
  }

  Future<List<Article>> callShowStories() async {
    return await repository.getShowStories();
  }

  Future<List<Article>> callJobStories() async {
    return await repository.getJobStories();
  }

  Future<Article?> callById(int id) async {
    return await repository.getArticleById(id);
  }
}
