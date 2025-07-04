// data/repositories/article_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/local/article_local_datasource.dart';
import '../datasources/remote/article_remote_datasource.dart';
import '../models/article_model.dart';
import '../../core/constants/app_constants.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource _localDataSource = ArticleLocalDataSource();
  final ArticleRemoteDataSource _remoteDataSource = ArticleRemoteDataSource();

  @override
  Future<List<Article>> getTopStories({int page = 0, int limit = 20}) async {
    final isConnected = await _isConnected();

    if (isConnected) {
      try {
        final storyIds = await _remoteDataSource.getTopStoryIds();
        final start = page * limit;
        final end = (start + limit).clamp(0, storyIds.length);
        final pageIds = storyIds.sublist(start, end);

        final remoteArticles = await _remoteDataSource.getArticlesByIds(
          pageIds,
        );

        // Update local cache and favorite status
        final articlesWithFavorites = <ArticleModel>[];
        for (final article in remoteArticles) {
          final localArticle = await _localDataSource.getArticleById(
            article.id,
          );
          final isFavorite = localArticle?.isFavorite ?? false;
          articlesWithFavorites.add(article.copyWithFavorite(isFavorite));
        }

        await _localDataSource.insertArticles(articlesWithFavorites);
        return articlesWithFavorites;
      } catch (e) {
        // Fallback to local data
        return await _getLocalArticles(page, limit);
      }
    } else {
      return await _getLocalArticles(page, limit);
    }
  }

  @override
  Future<List<Article>> getNewStories() async {
    return await _getStoriesByType(_remoteDataSource.getNewStoryIds);
  }

  @override
  Future<List<Article>> getAskStories() async {
    return await _getStoriesByType(_remoteDataSource.getAskStoryIds);
  }

  @override
  Future<List<Article>> getShowStories() async {
    return await _getStoriesByType(_remoteDataSource.getShowStoryIds);
  }

  @override
  Future<List<Article>> getJobStories() async {
    return await _getStoriesByType(_remoteDataSource.getJobStoryIds);
  }

  Future<List<Article>> _getStoriesByType(
    Future<List<int>> Function() getIds,
  ) async {
    final isConnected = await _isConnected();

    if (isConnected) {
      try {
        final storyIds = await getIds();
        final limitedIds = storyIds.take(AppConstants.articlesPerPage).toList();
        final remoteArticles = await _remoteDataSource.getArticlesByIds(
          limitedIds,
        );

        // Update with favorite status
        final articlesWithFavorites = <ArticleModel>[];
        for (final article in remoteArticles) {
          final localArticle = await _localDataSource.getArticleById(
            article.id,
          );
          final isFavorite = localArticle?.isFavorite ?? false;
          articlesWithFavorites.add(article.copyWithFavorite(isFavorite));
        }

        await _localDataSource.insertArticles(articlesWithFavorites);
        return articlesWithFavorites;
      } catch (e) {
        return await _getLocalArticles(0, AppConstants.articlesPerPage);
      }
    } else {
      return await _getLocalArticles(0, AppConstants.articlesPerPage);
    }
  }

  @override
  Future<Article?> getArticleById(int id) async {
    // First check local cache
    final localArticle = await _localDataSource.getArticleById(id);

    final isConnected = await _isConnected();
    if (isConnected) {
      try {
        final remoteArticle = await _remoteDataSource.getArticleById(id);
        if (remoteArticle != null) {
          final isFavorite = localArticle?.isFavorite ?? false;
          final articleWithFavorite = remoteArticle.copyWithFavorite(
            isFavorite,
          );
          await _localDataSource.insertArticle(articleWithFavorite);
          return articleWithFavorite;
        }
      } catch (e) {
        // Continue to return local article if available
      }
    }

    return localArticle;
  }

  @override
  Future<List<Article>> getFavoriteArticles() async {
    return await _localDataSource.getFavoriteArticles();
  }

  @override
  Future<void> addToFavorites(int articleId) async {
    await _localDataSource.updateFavoriteStatus(articleId, true);
  }

  @override
  Future<void> removeFromFavorites(int articleId) async {
    await _localDataSource.updateFavoriteStatus(articleId, false);
  }

  @override
  Future<void> cleanupOldArticles() async {
    await _localDataSource.deleteOldNonFavoriteArticles();
  }

  Future<List<Article>> _getLocalArticles(int page, int limit) async {
    return await _localDataSource.getArticles(
      limit: limit,
      offset: page * limit,
      orderBy: 'time DESC',
    );
  }

  Future<bool> _isConnected() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}
