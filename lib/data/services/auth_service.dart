import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';
import 'package:pool_and_chill_app/data/models/login/index.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<AuthResponseModel> login(
    String email,
    String password,
  ) async {
    final response = await api.post(
      ApiRoutes.login,
      withAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return AuthResponseModel.fromJson(data);
  }
}
