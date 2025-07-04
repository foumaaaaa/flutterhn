// TODO: Implementer le code pour presentation/providers/article_provider
// presentation/providers/article_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/article.dart';
import '../../data/repositories/article_repository_impl.dart';

enum ArticleStatus { initial, loading, loaded, error }

class ArticleProvider extends ChangeNotifier {
  final ArticleRepositoryImpl _repository = ArticleRepositoryImpl();

  final List<Article> _articles = [];
  final List<Article> _topStories = [];
  List<Article> _newStories = [];
  List<Article> _askStories = [];
  List<Article> _showStories = [];
  List<Article> _jobStories = [];

  ArticleStatus _status = ArticleStatus.initial;
  String? _errorMessage;
  bool _hasMoreArticles = true;
  int _currentPage = 0;

  // Getters
  List<Article> get articles => _articles;
  List<Article> get topStories => _topStories;
  List<Article> get newStories => _newStories;
  List<Article> get askStories => _askStories;
  List<Article> get showStories => _showStories;
  List<Article> get jobStories => _jobStories;
  ArticleStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasMoreArticles => _hasMoreArticles;
  bool get isLoading => _status == ArticleStatus.loading;

  Future<void> loadTopStories({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreArticles = true;
      _articles.clear();
    } else if (!_hasMoreArticles || _status == ArticleStatus.loading) {
      return;
    }

    _setStatus(ArticleStatus.loading);

    try {
      final newArticles = await _repository.getTopStories(
        page: _currentPage,
        limit: 20,
      );

      if (newArticles.isEmpty) {
        _hasMoreArticles = false;
      } else {
        _articles.addAll(newArticles);
        _currentPage++;
      }

      _setStatus(ArticleStatus.loaded);
    } catch (e) {
      _setError('Erreur lors du chargement des articles: $e');
    }
  }

  Future<void> loadNewStories() async {
    _setStatus(ArticleStatus.loading);
    try {
      _newStories = await _repository.getNewStories();
      _setStatus(ArticleStatus.loaded);
    } catch (e) {
      _setError('Erreur lors du chargement des nouveaux articles: $e');
    }
  }

  Future<void> loadAskStories() async {
    _setStatus(ArticleStatus.loading);
    try {
      _askStories = await _repository.getAskStories();
      _setStatus(ArticleStatus.loaded);
    } catch (e) {
      _setError('Erreur lors du chargement des questions: $e');
    }
  }

  Future<void> loadShowStories() async {
    _setStatus(ArticleStatus.loading);
    try {
      _showStories = await _repository.getShowStories();
      _setStatus(ArticleStatus.loaded);
    } catch (e) {
      _setError('Erreur lors du chargement des projets: $e');
    }
  }

  Future<void> loadJobStories() async {
    _setStatus(ArticleStatus.loading);
    try {
      _jobStories = await _repository.getJobStories();
      _setStatus(ArticleStatus.loaded);
    } catch (e) {
      _setError('Erreur lors du chargement des offres d\'emploi: $e');
    }
  }

  Future<Article?> getArticleById(int id) async {
    try {
      return await _repository.getArticleById(id);
    } catch (e) {
      _setError('Erreur lors du chargement de l\'article: $e');
      return null;
    }
  }

  void _setStatus(ArticleStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = ArticleStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
