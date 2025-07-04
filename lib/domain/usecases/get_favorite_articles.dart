// TODO: Implementer le code pour domain/usecases/get_favorite_articles
// domain/usecases/get_favorite_articles.dart
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetFavoriteArticles {
  final ArticleRepository repository;

  GetFavoriteArticles(this.repository);

  Future<List<Article>> call() async {
    return await repository.getFavoriteArticles();
  }
}
