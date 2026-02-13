import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';
import 'package:pool_and_chill_app/data/models/login/index.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await api.post(
      ApiRoutes.login,
      withAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) {
          throw Exception(message.join('\n'));
        }
        throw Exception(message ?? 'Error al iniciar sesión');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al iniciar sesión');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  Future<RegisterResponseModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? dateOfBirth,
    int? gender,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'password': password,
      'type': 2,
    };

    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (gender != null) body['gender'] = gender;

    final response = await api.post(
      ApiRoutes.register,
      withAuth: false,
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RegisterResponseModel.fromJson(data);
    }

    final error = jsonDecode(response.body) as Map<String, dynamic>;
    final message = error['message'];

    if (message is List) {
      throw Exception(message.join('\n'));
    }

    throw Exception(message ?? 'Error al registrar');
  }

  Future<void> logout() async {
    await api.post(ApiRoutes.logout, withAuth: true);
  }

  Future<AuthResponseModel> refresh(String refreshToken) async {
    final response = await api.post(
      ApiRoutes.refresh,
      withAuth: false,
      body: {
        'refreshToken': refreshToken,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Refresh failed');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }
}
