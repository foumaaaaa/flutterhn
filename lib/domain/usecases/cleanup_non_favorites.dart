// TODO: Implementer le code pour domain/usecases/cleanup_non_favorites
// domain/usecases/cleanup_non_favorites.dart
import '../repositories/article_repository.dart';

class CleanupNonFavorites {
  final ArticleRepository repository;

  CleanupNonFavorites(this.repository);

  Future<void> call() async {
    await repository.cleanupOldArticles();
  }
}
