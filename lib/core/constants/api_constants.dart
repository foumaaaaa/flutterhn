// TODO: Implementer le code pour core/constants/api_constants
// core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';
  static const String itemEndpoint = '/item';
  static const String userEndpoint = '/user';
  static const String topStoriesEndpoint = '/topstories.json';
  static const String newStoriesEndpoint = '/newstories.json';
  static const String bestStoriesEndpoint = '/beststories.json';
  static const String askStoriesEndpoint = '/askstories.json';
  static const String showStoriesEndpoint = '/showstories.json';
  static const String jobStoriesEndpoint = '/jobstories.json';
  static const String maxItemEndpoint = '/maxitem.json';

  static String getItemUrl(int id) => '$baseUrl$itemEndpoint/$id.json';
  static String getUserUrl(String id) => '$baseUrl$userEndpoint/$id.json';
}
