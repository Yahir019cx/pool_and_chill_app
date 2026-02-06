import 'dart:convert';
import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';

class PropertyService {
  final ApiClient _apiClient;

  PropertyService(this._apiClient);

  /// Obtiene las amenidades filtradas por categorías
  /// [categories] puede ser: "pool", "cabin", "camping" o combinaciones "pool,cabin"
  Future<List<AmenityModel>> getAmenities(String categories) async {
    final response = await _apiClient.get(
      ApiRoutes.amenitiesByCategory(categories),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => AmenityModel.fromJson(item)).toList();
    }

    throw Exception('Error al obtener amenidades: ${response.statusCode}');
  }

  /// Obtiene amenidades agrupadas por categoría
  Future<AmenitiesByCategory> getAmenitiesGrouped(String categories) async {
    final amenities = await getAmenities(categories);
    return AmenitiesByCategory.fromList(amenities);
  }

  /// Obtiene las propiedades del host autenticado
  Future<List<MyPropertyModel>> getMyProperties() async {
    final response = await _apiClient.get(ApiRoutes.myProperties);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      final List<dynamic> properties = data['properties'] ?? [];
      return properties
          .map((item) => MyPropertyModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    }

    throw Exception('Error al obtener propiedades: ${response.statusCode}');
  }
}
