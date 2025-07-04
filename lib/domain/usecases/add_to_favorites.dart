// domain/usecases/add_to_favorites.dart
import '../repositories/article_repository.dart';

class AddToFavorites {
  final ArticleRepository repository;

  AddToFavorites(this.repository);

  Future<void> call(int articleId) async {
    await repository.addToFavorites(articleId);
  }
}
