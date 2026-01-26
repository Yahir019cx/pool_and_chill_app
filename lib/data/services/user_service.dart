import 'dart:convert';
import 'package:pool_and_chill_app/data/api/index.dart';
import 'package:pool_and_chill_app/data/models/user/index.dart';

class UserService {
  final ApiClient api;

  UserService(this.api);

  Future<UserProfileModel> getMe() async {
    final response = await api.get(ApiRoutes.me);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user profile');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return UserProfileModel.fromJson(data);
  }

  /// Actualizar imagen de perfil
  /// Envía la URL de Firebase Storage al backend
  Future<UserProfileModel> updateProfileImage(String imageUrl) async {
    final response = await api.patch(
      ApiRoutes.updateImage,
      body: {'profileImageUrl': imageUrl},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserProfileModel.fromJson(data);
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'URL de imagen inválida');
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  /// Eliminar imagen de perfil
  Future<UserProfileModel> deleteProfileImage() async {
    final response = await api.delete(ApiRoutes.updateImage);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return UserProfileModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
