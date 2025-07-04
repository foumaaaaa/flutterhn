// TODO: Implementer le code pour presentation/providers/favorites_provider
// presentation/providers/favorites_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/article.dart';
import '../../data/repositories/article_repository_impl.dart';

class FavoritesProvider extends ChangeNotifier {
  final ArticleRepositoryImpl _repository = ArticleRepositoryImpl();

  List<Article> _favoriteArticles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Article> get favoriteArticles => _favoriteArticles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteArticles = await _repository.getFavoriteArticles();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des favoris: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(Article article) async {
    try {
      await _repository.addToFavorites(article.id);

      // Update local list
      final updatedArticle = article.copyWith(isFavorite: true);
      final index = _favoriteArticles.indexWhere((a) => a.id == article.id);

      if (index == -1) {
        _favoriteArticles.add(updatedArticle);
      } else {
        _favoriteArticles[index] = updatedArticle;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout aux favoris: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(int articleId) async {
    try {
      await _repository.removeFromFavorites(articleId);

      // Update local list
      _favoriteArticles.removeWhere((article) => article.id == articleId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression des favoris: $e';
      notifyListeners();
    }
  }

  bool isFavorite(int articleId) {
    return _favoriteArticles.any((article) => article.id == articleId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
