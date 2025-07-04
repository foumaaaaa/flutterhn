// TODO: Implementer le code pour presentation/screens/favorites/widgets/favorite_article_item
// presentation/screens/favorites/widgets/favorite_article_item.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../domain/entities/article.dart';
import '../../../widgets/shared/favorite_button.dart';

class FavoriteArticleItem extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const FavoriteArticleItem({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              const SizedBox(height: 8),
              _buildTitle(theme),
              const SizedBox(height: 8),
              _buildMetadata(theme),
              if (article.hasText) ...[
                const SizedBox(height: 8),
                _buildPreview(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'FAVORI',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        FavoriteButton(article: article),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      article.title ?? 'Sans titre',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Wrap(
      spacing: 16,
      children: [
        _buildMetadataItem(
          icon: Icons.person_outline,
          text: article.author ?? 'Anonyme',
          theme: theme,
        ),
        _buildMetadataItem(
          icon: Icons.arrow_upward,
          text: '${article.score}',
          theme: theme,
        ),
        if (article.hasComments)
          _buildMetadataItem(
            icon: Icons.comment_outlined,
            text: '${article.descendants}',
            theme: theme,
          ),
        _buildMetadataItem(
          icon: Icons.schedule,
          text: timeago.format(article.publishedDate, locale: 'fr'),
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMetadataItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (article.text == null) return const SizedBox.shrink();

    // Extract plain text from HTML
    final plainText = article.text!
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        plainText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
