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
  Future<void> updateProfileImage(String imageUrl) async {
    final response = await api.patch(
      ApiRoutes.updateImage,
      body: {'profileImageUrl': imageUrl},
    );

    if (response.statusCode == 200) {
      return; // Éxito - el perfil se refrescará después
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
  Future<void> deleteProfileImage() async {
    final response = await api.delete(ApiRoutes.updateImage);

    if (response.statusCode == 200) {
      return; // Éxito - el perfil se refrescará después
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  /// Completar onboarding de host
  Future<void> completeHostOnboarding() async {
    final response = await api.post(ApiRoutes.completeHostOnboarding);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al completar el registro');
    }
  }

  /// Actualizar perfil del usuario
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? phoneNumber,
    String? location,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (location != null) body['location'] = location;

    final response = await api.patch(
      ApiRoutes.updateProfile,
      body: body,
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      // NestJS puede retornar message como String o List<String>
      final raw = error['message'];
      final msg = raw is List ? raw.first.toString() : raw?.toString() ?? '';
      throw Exception(_parsearErrorPerfil(msg));
    } else if (response.statusCode == 401) {
      throw Exception('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.');
    } else {
      throw Exception('No pudimos guardar los cambios. Intenta de nuevo.');
    }
  }

  /// Traduce mensajes técnicos del backend a mensajes amigables para el usuario
  static String _parsearErrorPerfil(String msg) {
    final lower = msg.toLowerCase();

    if (lower.contains('displayname')) {
      return 'Usa tu nombre y apellido reales.';
    }
    if (lower.contains('phonenumber') || lower.contains('phone')) {
      return 'El número de teléfono no es válido.';
    }
    if (lower.contains('bio')) {
      return 'La biografía contiene caracteres no permitidos.';
    }
    if (lower.contains('location')) {
      return 'La ubicación seleccionada no es válida.';
    }
    if (lower.contains('imagen') || lower.contains('image') || lower.contains('url')) {
      return 'La imagen no pudo procesarse. Intenta con otra foto.';
    }

    return 'Verifica los datos e intenta de nuevo.';
  }
}
