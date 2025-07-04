// presentation/screens/article_detail/widgets/comment_item_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../../../../domain/entities/comment.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../providers/comment_provider.dart';

class CommentItemWidget extends StatefulWidget {
  final Comment comment;
  final Function(List<int>)? onReplyTap;

  const CommentItemWidget({super.key, required this.comment, this.onReplyTap});

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isContentExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final levelIndent = widget.comment.level * 20.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.only(
          left: levelIndent,
          bottom: 12,
          top: widget.comment.level == 0 ? 8 : 0,
          right: 8,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getCardGradient(isDark),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                blurRadius: widget.comment.level == 0 ? 20 : 12,
                offset: Offset(0, widget.comment.level == 0 ? 8 : 4),
              ),
            ],
            border: Border.all(
              color:
                  widget.comment.level > 0
                      ? _getLevelColor(theme).withOpacity(0.3)
                      : (isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05)),
              width: widget.comment.level > 0 ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, isDark),
              if (_isContentExpanded) ...[
                _buildContent(theme, isDark),
                if (widget.comment.hasReplies) _buildReplyButton(theme, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCardGradient(bool isDark) {
    if (widget.comment.level == 0) {
      return isDark
          ? [const Color(0xFF374151), const Color(0xFF1F2937)]
          : [Colors.white, const Color(0xFFF8FAFC)];
    } else if (widget.comment.level == 1) {
      return isDark
          ? [const Color(0xFF4B5563), const Color(0xFF374151)]
          : [const Color(0xFFFAFAFA), const Color(0xFFF1F5F9)];
    } else if (widget.comment.level == 2) {
      return isDark
          ? [const Color(0xFF6B7280), const Color(0xFF4B5563)]
          : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)];
    } else {
      return isDark
          ? [const Color(0xFF9CA3AF), const Color(0xFF6B7280)]
          : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)];
    }
  }

  Color _getLevelColor(ThemeData theme) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
    ];
    return colors[widget.comment.level % colors.length];
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isContentExpanded = !_isContentExpanded),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Indicateur de niveau avec design moderne
              if (widget.comment.level > 0) ...[
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getLevelColor(theme),
                        _getLevelColor(theme).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: _getLevelColor(theme).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Icône d'expansion moderne
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isContentExpanded ? Icons.remove_rounded : Icons.add_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // Avatar et nom d'utilisateur
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      widget.comment.author != null
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        widget.comment.author != null
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  widget.comment.author != null
                      ? Icons.person_rounded
                      : Icons.person_off_rounded,
                  size: 16,
                  color:
                      widget.comment.author != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.author ?? '[supprimé]',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            widget.comment.author != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeago.format(
                          widget.comment.publishedDate,
                          locale: 'fr',
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Badge du nombre de réponses moderne
              if (widget.comment.hasReplies) ...[
                const SizedBox(width: 12),
                Consumer<CommentProvider>(
                  builder: (context, provider, child) {
                    final isExpanded = provider.isCommentExpanded(
                      widget.comment.id,
                    );
                    final isLoading = provider.isLoadingReplies(
                      widget.comment.id,
                    );

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              isExpanded
                                  ? [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ]
                                  : [
                                    const Color(0xFFEC4899),
                                    const Color(0xFFF472B6),
                                  ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isExpanded
                                    ? theme.colorScheme.primary
                                    : const Color(0xFFEC4899))
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoading)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.comment.kids.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    if (!widget.comment.isVisible ||
        widget.comment.text == null ||
        widget.comment.text!.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.error.withOpacity(0.1),
              theme.colorScheme.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '[Commentaire supprimé]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Html(
        data: widget.comment.text!,
        style: {
          "body": Style(
            margin: Margins.zero,
            fontSize: FontSize(15),
            lineHeight: const LineHeight(1.6),
            color: theme.colorScheme.onSurface,
          ),
          "p": Style(margin: Margins.only(bottom: 12)),
          "pre": Style(
            backgroundColor:
                isDark
                    ? Colors.black.withOpacity(0.5)
                    : const Color(0xFFF1F5F9),
            padding: HtmlPaddings.all(16),
            margin: Margins.symmetric(vertical: 8),
          ),
          "code": Style(
            backgroundColor:
                isDark
                    ? Colors.black.withOpacity(0.5)
                    : const Color(0xFFF1F5F9),
            padding: HtmlPaddings.symmetric(horizontal: 8, vertical: 4),
            color: theme.colorScheme.primary,
          ),
          "a": Style(
            color: theme.colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          "blockquote": Style(
            margin: Margins.symmetric(vertical: 12),
            padding: HtmlPaddings.only(left: 16),
            border: Border(
              left: BorderSide(color: theme.colorScheme.primary, width: 4),
            ),
            backgroundColor:
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
          ),
          "i": Style(fontStyle: FontStyle.italic),
          "em": Style(fontStyle: FontStyle.italic),
          "b": Style(fontWeight: FontWeight.bold),
          "strong": Style(fontWeight: FontWeight.bold),
        },
        onAnchorTap: (url, attributes, element) {
          if (url != null) {
            UrlLauncherHelper.launchUrl(url);
          }
        },
      ),
    );
  }

  Widget _buildReplyButton(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Consumer<CommentProvider>(
        builder: (context, provider, child) {
          final isExpanded = provider.isCommentExpanded(widget.comment.id);
          final isLoading = provider.isLoadingReplies(widget.comment.id);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                    (isLoading || widget.onReplyTap == null)
                        ? null
                        : () {
                          widget.onReplyTap!(widget.comment.kids);
                        },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isExpanded
                            ? 'Masquer les réponses'
                            : 'Voir les ${widget.comment.kids.length} réponse${widget.comment.kids.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.comment.kids.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
