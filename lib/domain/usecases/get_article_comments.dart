// TODO: Implementer le code pour domain/usecases/get_article_comments
// domain/usecases/get_article_comments.dart
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetArticleComments {
  final CommentRepository repository;

  GetArticleComments(this.repository);

  Future<List<Comment>> call(int articleId, List<int> commentIds) async {
    return await repository.getCommentsForArticle(articleId, commentIds);
  }
}
