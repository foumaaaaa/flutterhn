// presentation/widgets/shared/favorite_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/article.dart';
import '../../providers/favorites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final Article article;

  const FavoriteButton({super.key, required this.article});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(widget.article.id);

        return AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _rotationAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.1,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient:
                        isFavorite
                            ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
                            )
                            : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  isDark
                                      ? [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ]
                                      : [
                                        Colors.black.withOpacity(0.05),
                                        Colors.black.withOpacity(0.02),
                                      ],
                            ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isFavorite
                              ? const Color(0xFFFF6B9D).withOpacity(0.5)
                              : (isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1)),
                      width: 2,
                    ),
                    boxShadow:
                        isFavorite
                            ? [
                              BoxShadow(
                                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color:
                                    isDark
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          () => _toggleFavorite(favoritesProvider, isFavorite),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse effect for favorites
                          if (isFavorite)
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          // Heart icon
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(isFavorite),
                              color:
                                  isFavorite
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black.withOpacity(0.6)),
                              size: 22,
                            ),
                          ),
                          // Sparkle effects
                          if (isFavorite) ..._buildSparkles(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(
        top: 8,
        right: 8,
        child: Transform.scale(
          scale: _pulseAnimation.value * 0.5,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 8,
        left: 8,
        child: Transform.scale(
          scale: _pulseAnimation.value * 0.3,
          child: Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      Positioned(
        top: 12,
        left: 12,
        child: Transform.scale(
          scale: _pulseAnimation.value * 0.4,
          child: Container(
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ];
  }

  void _toggleFavorite(FavoritesProvider provider, bool isFavorite) async {
    // Scale animation
    await _scaleController.forward();
    _scaleController.reverse();

    // Rotation animation
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });

    if (isFavorite) {
      provider.removeFromFavorites(widget.article.id);
      _showSnackBar('Article retiré des favoris', false);
      _pulseController.stop();
    } else {
      provider.addToFavorites(widget.article);
      _showSnackBar('Article ajouté aux favoris', true);
      // Start pulse animation for favorites
      _pulseController.repeat(reverse: true);
    }
  }

  void _showSnackBar(String message, bool isAdded) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isAdded
                            ? [const Color(0xFFFF6B9D), const Color(0xFFFF8E8E)]
                            : [
                              const Color(0xFF6B7280),
                              const Color(0xFF9CA3AF),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isAdded
                              ? const Color(0xFFFF6B9D)
                              : const Color(0xFF6B7280))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isAdded
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
