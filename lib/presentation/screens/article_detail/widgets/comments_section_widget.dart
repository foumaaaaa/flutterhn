// presentation/screens/article_detail/widgets/comments_section_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/comment_provider.dart';
import '../../../widgets/common/error_widget.dart';
import 'comment_item_widget.dart';

class CommentsSection extends StatelessWidget {
  final int articleId;
  final List<int>? originalCommentIds;

  const CommentsSection({
    super.key,
    required this.articleId,
    this.originalCommentIds,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des commentaires...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomErrorWidget(
                message: provider.errorMessage!,
                onRetry: () => _retryLoadingComments(context, provider),
              ),
            ),
          );
        }

        // Utiliser la méthode hiérarchique pour récupérer tous les commentaires
        final hierarchicalComments = provider.getHierarchicalCommentsForArticle(
          articleId,
        );
        final topLevelCount = provider.getTopLevelCommentCount(articleId);

        if (hierarchicalComments.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun commentaire disponible',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez le premier à commenter cet article',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= hierarchicalComments.length) return null;

            final comment = hierarchicalComments[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CommentItemWidget(
                comment: comment,
                onReplyTap:
                    (replyIds) => _handleReplyTap(
                      context,
                      provider,
                      comment.id,
                      replyIds,
                    ),
              ),
            );
          }, childCount: hierarchicalComments.length),
        );
      },
    );
  }

  void _retryLoadingComments(BuildContext context, CommentProvider provider) {
    provider.clearError();

    if (originalCommentIds != null) {
      provider.loadCommentsForArticle(articleId, originalCommentIds!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de recharger les commentaires. Veuillez actualiser la page.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleReplyTap(
    BuildContext context,
    CommentProvider provider,
    int commentId,
    List<int> replyIds,
  ) {
    if (provider.isLoadingReplies(commentId)) {
      // Déjà en cours de chargement, ne rien faire
      return;
    }

    if (provider.isCommentExpanded(commentId)) {
      // Si déjà étendu, réduire
      provider.toggleCommentExpansion(commentId);
    } else {
      // Si réduit, charger et étendre
      provider.loadRepliesForComment(commentId, replyIds);
    }
  }
}
