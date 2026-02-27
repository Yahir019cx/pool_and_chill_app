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
        final detail = error['error'];

        // Priorizar mensajes específicos
        if (message is List) {
          throw Exception(message.join('\n'));
        }

        // Si el backend envía un mensaje genérico como "Error al procesar login"
        // pero el detalle real va en otra propiedad (por ejemplo `error`),
        // usamos ese detalle para mostrar una razón más clara al usuario.
        if (message is String &&
            message.isNotEmpty &&
            message != 'Error al procesar login') {
          throw Exception(message);
        }

        if (detail is String && detail.isNotEmpty) {
          throw Exception(detail);
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

  Future<AuthResponseModel> loginWithApple({
    required String identityToken,
    String? firstName,
    String? lastName,
  }) async {
    final body = <String, dynamic>{'identityToken': identityToken};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;

    final response = await api.post(
      ApiRoutes.loginWithApple,
      withAuth: false,
      body: body,
    );

    if (response.statusCode == 401) {
      throw Exception('Token de Apple inválido o expirado');
    }
    if (response.statusCode == 403) {
      throw Exception('Cuenta suspendida o bloqueada');
    }
    if (response.statusCode == 400) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Datos inválidos');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Datos inválidos');
      }
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al iniciar sesión con Apple');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al iniciar sesión con Apple');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> loginWithGoogle(String idToken) async {
    final response = await api.post(
      ApiRoutes.loginWithGoogle,
      withAuth: false,
      body: {'idToken': idToken},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al iniciar sesión con Google');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al iniciar sesión con Google');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  /// Envía correo de restablecimiento de contraseña.
  /// Lanza [Exception] si el email es inválido (400).
  Future<void> forgotPassword(String email) async {
    final response = await api.post(
      ApiRoutes.forgotPassword,
      withAuth: false,
      body: {'email': email},
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body) as Map<String, dynamic>;
      final message = error['message'];
      if (message is List) {
        throw Exception(message.join('\n'));
      }
      throw Exception(message ?? 'Error al enviar el correo');
    }
  }

  Future<void> logout() async {
    await api.post(ApiRoutes.logout, withAuth: true);
  }

  Future<RefreshResponseModel> refresh(String refreshToken) async {
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
    return RefreshResponseModel.fromJson(data);
  }
}
