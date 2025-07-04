// data/datasources/remote/article_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/article_model.dart';

class ArticleRemoteDataSource {
  final http.Client client;

  ArticleRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<List<int>> getTopStoryIds() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.topStoriesEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load top story IDs');
    }
  }

  Future<List<int>> getNewStoryIds() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.newStoriesEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load new story IDs');
    }
  }

  Future<List<int>> getAskStoryIds() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.askStoriesEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load Ask HN story IDs');
    }
  }

  Future<List<int>> getShowStoryIds() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.showStoriesEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load Show HN story IDs');
    }
  }

  Future<List<int>> getJobStoryIds() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.jobStoriesEndpoint}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load job story IDs');
    }
  }

  Future<ArticleModel?> getArticleById(int id) async {
    final response = await client.get(Uri.parse(ApiConstants.getItemUrl(id)));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json.isEmpty) return null;
      return ArticleModel.fromJson(json);
    } else {
      throw Exception('Failed to load article $id');
    }
  }

  Future<List<ArticleModel>> getArticlesByIds(List<int> ids) async {
    final List<ArticleModel> articles = [];

    // Batch requests to avoid overwhelming the API
    const batchSize = 10;
    for (int i = 0; i < ids.length; i += batchSize) {
      final batch = ids.skip(i).take(batchSize);
      final futures = batch.map((id) => getArticleById(id));
      final results = await Future.wait(futures);

      for (final article in results) {
        if (article != null) {
          articles.add(article);
        }
      }
    }

    return articles;
  }
}
