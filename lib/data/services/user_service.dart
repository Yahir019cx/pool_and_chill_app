import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_routes.dart';

class UserService {
  final ApiClient api;

  UserService(this.api);

  Future<Map<String, dynamic>> getMe() async {
    final response = await api.get(ApiRoutes.me);

    if (response.statusCode != 200) {
      throw Exception('Unauthorized');
    }

    return jsonDecode(response.body);
  }
}
