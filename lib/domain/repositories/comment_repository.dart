// TODO: Implementer le code pour domain/repositories/comment_repository
// domain/repositories/comment_repository.dart
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentsForArticle(
    int articleId,
    List<int> commentIds,
  );
  Future<List<Comment>> getRepliesForComment(int commentId, List<int> replyIds);
}
