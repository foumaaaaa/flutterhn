// TODO: Implementer le code pour data/datasources/remote/user_remote_datasource
// data/datasources/remote/user_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

class UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<UserModel?> getUserById(String id) async {
    final response = await client.get(Uri.parse(ApiConstants.getUserUrl(id)));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json.isEmpty) return null;
      return UserModel.fromJson(json);
    } else {
      throw Exception('Failed to load user $id');
    }
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    final List<UserModel> users = [];

    for (final id in ids) {
      try {
        final user = await getUserById(id);
        if (user != null) {
          users.add(user);
        }
      } catch (e) {
        // Continue with other users if one fails
        continue;
      }
    }

    return users;
  }
}
