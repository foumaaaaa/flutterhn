// core/network/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    http.Client? client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client.get(uri).timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException(message: 'Pas de connexion Internet');
    } on HttpException {
      throw const NetworkException(message: 'Erreur HTTP');
    } catch (e) {
      throw ServerException(message: 'Erreur inattendue: $e');
    }
  }

  Future<List<dynamic>> getList(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        } else {
          throw const ServerException(
            message: 'Réponse inattendue: attendu une liste',
          );
        }
      } else {
        throw ServerException(
          message: 'Erreur serveur',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const NetworkException(message: 'Pas de connexion Internet');
    } on HttpException {
      throw const NetworkException(message: 'Erreur HTTP');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Erreur inattendue: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          return json.decode(response.body);
        } catch (e) {
          throw const ServerException(message: 'Erreur de décodage JSON');
        }
      case 400:
        throw const ServerException(
          message: 'Requête invalide',
          statusCode: 400,
        );
      case 401:
        throw const ServerException(message: 'Non autorisé', statusCode: 401);
      case 403:
        throw const ServerException(message: 'Accès interdit', statusCode: 403);
      case 404:
        throw const ServerException(
          message: 'Ressource non trouvée',
          statusCode: 404,
        );
      case 500:
        throw const ServerException(
          message: 'Erreur serveur interne',
          statusCode: 500,
        );
      default:
        throw ServerException(
          message: 'Erreur inconnue',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() {
    client.close();
  }
}
