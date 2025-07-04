// data/repositories/comment_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/local/comment_local_datasource.dart';
import '../datasources/remote/comment_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentLocalDataSource _localDataSource = CommentLocalDataSource();
  final CommentRemoteDataSource _remoteDataSource = CommentRemoteDataSource();

  @override
  Future<List<Comment>> getCommentsForArticle(
    int articleId,
    List<int> commentIds,
  ) async {
    final isConnected = await _isConnected();

    if (isConnected) {
      try {
        // Charger les commentaires de niveau 0 depuis l'API
        final topLevelComments = await _remoteDataSource.getCommentsByIds(
          commentIds,
          level: 0,
        );

        // Construire l'arbre hiérarchique avec tous les niveaux
        final commentTree = await _buildCompleteCommentTree(topLevelComments);

        // Sauvegarder en local pour utilisation hors ligne
        await _localDataSource.insertComments(commentTree, articleId);

        return commentTree;
      } catch (e) {
        print('Erreur lors du chargement depuis l\'API: $e');
        // Fallback vers les données locales
        return await _localDataSource.getCommentsForArticle(articleId);
      }
    } else {
      return await _localDataSource.getCommentsForArticle(articleId);
    }
  }

  @override
  Future<List<Comment>> getRepliesForComment(
    int commentId,
    List<int> replyIds,
  ) async {
    final isConnected = await _isConnected();

    if (isConnected) {
      try {
        // Déterminer le niveau des réponses
        final parentComment = await _getCommentFromCache(commentId);
        final childLevel = (parentComment?.level ?? 0) + 1;

        // Charger les réponses avec le bon niveau
        final replies = await _remoteDataSource.getCommentsByIds(
          replyIds,
          level: childLevel,
        );

        // Construire récursivement l'arbre pour les réponses
        return await _buildCompleteCommentTree(replies);
      } catch (e) {
        print('Erreur lors du chargement des réponses: $e');
        return await _localDataSource.getRepliesForComment(commentId);
      }
    } else {
      return await _localDataSource.getRepliesForComment(commentId);
    }
  }

  /// Construit récursivement l'arbre complet des commentaires
  Future<List<Comment>> _buildCompleteCommentTree(
    List<CommentModel> comments,
  ) async {
    final List<Comment> processedComments = [];

    for (final comment in comments) {
      if (comment.hasReplies && comment.kids.isNotEmpty) {
        try {
          // Charger les réponses du commentaire
          final childLevel = comment.level + 1;
          final replies = await _remoteDataSource.getCommentsByIds(
            comment.kids,
            level: childLevel,
          );

          // Construire récursivement l'arbre pour les réponses
          final processedReplies = await _buildCompleteCommentTree(replies);

          // Créer un nouveau commentaire avec les réponses intégrées
          final commentWithReplies = CommentModel(
            id: comment.id,
            text: comment.text,
            author: comment.author,
            time: comment.time,
            kids: comment.kids,
            parent: comment.parent,
            isDeleted: comment.isDeleted,
            isDead: comment.isDead,
            level: comment.level,
          );

          processedComments.add(commentWithReplies);

          // Ajouter les réponses après le commentaire parent
          processedComments.addAll(processedReplies);
        } catch (e) {
          print(
            'Erreur lors du chargement des réponses pour ${comment.id}: $e',
          );
          // Ajouter le commentaire sans ses réponses en cas d'erreur
          processedComments.add(comment);
        }
      } else {
        // Commentaire sans réponses
        processedComments.add(comment);
      }
    }

    return processedComments;
  }

  /// Récupère un commentaire depuis le cache local ou l'API
  Future<Comment?> _getCommentFromCache(int commentId) async {
    try {
      // Essayer d'abord le cache local
      final localComment = await _localDataSource.getCommentById(commentId);
      if (localComment != null) return localComment;

      // Sinon, charger depuis l'API
      final isConnected = await _isConnected();
      if (isConnected) {
        return await _remoteDataSource.getCommentById(commentId);
      }
    } catch (e) {
      print('Erreur lors de la récupération du commentaire $commentId: $e');
    }
    return null;
  }

  Future<bool> _isConnected() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}
