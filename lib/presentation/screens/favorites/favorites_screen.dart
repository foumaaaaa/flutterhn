// TODO: Implementer le code pour presentation/screens/favorites/favorites_screen
// presentation/screens/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/no_data_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../home/widgets/article_list_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FavoritesProvider>().loadFavorites(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favoriteArticles.isEmpty) {
            return const LoadingWidget(message: 'Chargement des favoris...');
          }

          if (provider.errorMessage != null) {
            return CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () {
                provider.clearError();
                provider.loadFavorites();
              },
            );
          }

          if (provider.favoriteArticles.isEmpty) {
            return const NoDataWidget(
              title: 'Aucun favori',
              message:
                  'Vous n\'avez pas encore ajouté d\'articles à vos favoris.\n\nAppuyez sur le cœur pour sauvegarder vos articles préférés.',
              icon: Icons.favorite_outline,
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.favoriteArticles.length,
              itemBuilder: (context, index) {
                final article = provider.favoriteArticles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(article.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss:
                        (direction) => _confirmDismiss(context, article.title),
                    onDismissed: (direction) {
                      provider.removeFromFavorites(article.id);
                      _showRemovalSnackBar(context, article.title);
                    },
                    child: ArticleListItem(article: article),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context, String? title) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Retirer des favoris'),
          content: Text(
            'Voulez-vous retirer "${title ?? 'cet article'}" de vos favoris ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Retirer'),
            ),
          ],
        );
      },
    );
  }

  void _showRemovalSnackBar(BuildContext context, String? title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${title ?? 'Article'} retiré des favoris'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            // Could implement undo functionality here
          },
        ),
      ),
    );
  }
}
