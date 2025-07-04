// TODO: Implementer le code pour domain/usecases/remove_from_favorites
// domain/usecases/remove_from_favorites.dart
import '../repositories/article_repository.dart';

class RemoveFromFavorites {
  final ArticleRepository repository;

  RemoveFromFavorites(this.repository);

  Future<void> call(int articleId) async {
    await repository.removeFromFavorites(articleId);
  }
}
