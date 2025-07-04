// presentation/providers/comment_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../data/repositories/comment_repository_impl.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepositoryImpl _repository = CommentRepositoryImpl();

  final Map<int, List<Comment>> _commentsByArticle = {};
  final Set<int> _expandedComments = <int>{};
  final Set<int> _loadingReplies = <int>{};

  bool _isLoading = false;
  String? _errorMessage;

  List<Comment> getCommentsForArticle(int articleId) {
    return _commentsByArticle[articleId] ?? [];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isCommentExpanded(int commentId) {
    return _expandedComments.contains(commentId);
  }

  bool isLoadingReplies(int commentId) {
    return _loadingReplies.contains(commentId);
  }

  void toggleCommentExpansion(int commentId) {
    if (_expandedComments.contains(commentId)) {
      _expandedComments.remove(commentId);
    } else {
      _expandedComments.add(commentId);
    }
    notifyListeners();
  }

  Future<void> loadCommentsForArticle(
    int articleId,
    List<int> commentIds,
  ) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Chargement des commentaires pour l\'article $articleId...');
      final comments = await _repository.getCommentsForArticle(
        articleId,
        commentIds,
      );

      print(
        '${comments.length} commentaires chargés pour l\'article $articleId',
      );
      _commentsByArticle[articleId] = comments;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des commentaires: $e';
      print('Erreur CommentProvider.loadCommentsForArticle: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRepliesForComment(int commentId, List<int> replyIds) async {
    // Éviter de recharger si déjà en cours
    if (_loadingReplies.contains(commentId)) return;

    _loadingReplies.add(commentId);
    notifyListeners();

    try {
      print(
        'Chargement de ${replyIds.length} réponses pour le commentaire $commentId...',
      );

      final replies = await _repository.getRepliesForComment(
        commentId,
        replyIds,
      );
      print(
        '${replies.length} réponses chargées pour le commentaire $commentId',
      );

      // Insérer les réponses dans la liste principale
      _insertRepliesIntoCommentTree(commentId, replies);

      // Marquer le commentaire comme étendu
      _expandedComments.add(commentId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des réponses: $e';
      print('Erreur CommentProvider.loadRepliesForComment: $e');
    } finally {
      _loadingReplies.remove(commentId);
      notifyListeners();
    }
  }

  /// Insère les réponses dans l'arbre de commentaires à la bonne position
  void _insertRepliesIntoCommentTree(
    int parentCommentId,
    List<Comment> replies,
  ) {
    for (final articleId in _commentsByArticle.keys) {
      final comments = _commentsByArticle[articleId]!;
      final parentIndex = comments.indexWhere((c) => c.id == parentCommentId);

      if (parentIndex != -1) {
        // Trouver la position d'insertion (après le commentaire parent)
        int insertIndex = parentIndex + 1;

        // Supprimer les anciennes réponses si elles existent déjà
        comments.removeWhere((c) => c.parent == parentCommentId);

        // Insérer les nouvelles réponses
        comments.insertAll(insertIndex, replies);
        break;
      }
    }
  }

  /// Récupère tous les commentaires de manière hiérarchique pour l'affichage
  List<Comment> getHierarchicalCommentsForArticle(int articleId) {
    final allComments = getCommentsForArticle(articleId);
    final List<Comment> hierarchicalList = [];

    // Séparer les commentaires de niveau 0 (commentaires principaux)
    final topLevelComments = allComments.where((c) => c.level == 0).toList();

    for (final comment in topLevelComments) {
      hierarchicalList.add(comment);

      // Ajouter les réponses si le commentaire est étendu
      if (isCommentExpanded(comment.id)) {
        _addRepliesRecursively(hierarchicalList, comment, allComments);
      }
    }

    return hierarchicalList;
  }

  void _addRepliesRecursively(
    List<Comment> list,
    Comment parentComment,
    List<Comment> allComments,
  ) {
    // Trouver toutes les réponses directes à ce commentaire
    final directReplies =
        allComments.where((c) => c.parent == parentComment.id).toList();

    // Trier par timestamp
    directReplies.sort((a, b) => a.time.compareTo(b.time));

    for (final reply in directReplies) {
      list.add(reply);

      // Si cette réponse est étendue, ajouter ses réponses récursivement
      if (isCommentExpanded(reply.id)) {
        _addRepliesRecursively(list, reply, allComments);
      }
    }
  }

  /// Compte le nombre total de commentaires visibles (y compris les réponses étendues)
  int getVisibleCommentCount(int articleId) {
    return getHierarchicalCommentsForArticle(articleId).length;
  }

  /// Compte le nombre de commentaires de niveau 0
  int getTopLevelCommentCount(int articleId) {
    return getCommentsForArticle(articleId).where((c) => c.level == 0).length;
  }

  void clearCommentsForArticle(int articleId) {
    _commentsByArticle.remove(articleId);
    // Nettoyer aussi les états associés
    _expandedComments.clear();
    _loadingReplies.clear();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAll() {
    _commentsByArticle.clear();
    _expandedComments.clear();
    _loadingReplies.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
