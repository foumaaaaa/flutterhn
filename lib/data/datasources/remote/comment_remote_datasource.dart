// data/datasources/remote/comment_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/comment_model.dart';

class CommentRemoteDataSource {
  final http.Client client;

  CommentRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<CommentModel?> getCommentById(int id, {int level = 0}) async {
    try {
      final response = await client.get(
        Uri.parse(ApiConstants.getItemUrl(id)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Vérifier si le JSON est valide et contient un commentaire
        if (json.isEmpty) {
          print('Commentaire $id: JSON vide (probablement supprimé)');
          return null;
        }

        // Vérifier le type d'item - doit être un commentaire
        if (json['type'] != null && json['type'] != 'comment') {
          print('Item $id n\'est pas un commentaire: ${json['type']}');
          return null;
        }

        final comment = CommentModel.fromJson(json, level: level);

        // Filtrer les commentaires non visibles dès le chargement
        if (!comment.isVisible) {
          print('Commentaire $id non visible (supprimé/mort)');
          return null;
        }

        return comment;
      } else if (response.statusCode == 404) {
        print('Commentaire $id non trouvé (404)');
        return null;
      } else {
        throw Exception(
          'Échec du chargement du commentaire $id: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur lors du chargement du commentaire $id: $e');
      return null;
    }
  }

  Future<List<CommentModel>> getCommentsByIds(
    List<int> ids, {
    int level = 0,
  }) async {
    if (ids.isEmpty) return [];

    final List<CommentModel> comments = [];

    // Traiter les commentaires par batches pour éviter trop de requêtes simultanées
    const batchSize = 5; // Réduit pour éviter la surcharge de l'API

    for (int i = 0; i < ids.length; i += batchSize) {
      final batch = ids.skip(i).take(batchSize).toList();

      try {
        // Charger le batch avec un délai pour respecter les limites de l'API
        final batchResults = await Future.wait(
          batch.map((id) => getCommentById(id, level: level)),
          eagerError: false,
        );

        // Filtrer et ajouter les commentaires valides
        for (final comment in batchResults) {
          if (comment != null && comment.isVisible) {
            comments.add(comment);
          }
        }

        // Délai entre les batches pour respecter les limites de l'API
        if (i + batchSize < ids.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        print('Erreur lors du chargement du batch ${i ~/ batchSize}: $e');
        continue; // Continuer avec le batch suivant
      }
    }

    // Trier les commentaires par timestamp (plus anciens en premier)
    comments.sort((a, b) => a.time.compareTo(b.time));

    print(
      'Chargé ${comments.length} commentaires valides sur ${ids.length} IDs (niveau $level)',
    );
    return comments;
  }

  /// Méthode optimisée pour charger un commentaire avec toutes ses réponses
  Future<CommentModel?> getCommentWithAllReplies(
    int id, {
    int level = 0,
    int maxDepth = 5,
  }) async {
    if (level > maxDepth) {
      print('Profondeur maximale atteinte ($maxDepth) pour le commentaire $id');
      return null;
    }

    final comment = await getCommentById(id, level: level);

    if (comment == null || !comment.hasReplies) {
      return comment;
    }

    try {
      print(
        'Chargement de ${comment.kids.length} réponses pour le commentaire $id (niveau $level)',
      );

      // Charger toutes les réponses récursivement
      final replies = await getCommentsByIds(comment.kids, level: level + 1);

      print('${replies.length} réponses chargées pour le commentaire $id');
      return comment;
    } catch (e) {
      print(
        'Erreur lors du chargement des réponses pour le commentaire $id: $e',
      );
      return comment; // Retourner le commentaire sans ses réponses
    }
  }
}
