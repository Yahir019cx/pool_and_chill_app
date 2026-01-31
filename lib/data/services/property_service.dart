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
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AmenityModel.fromJson(json)).toList();
    }

    throw Exception('Error al obtener amenidades: ${response.statusCode}');
  }

  /// Obtiene amenidades agrupadas por categoría
  Future<AmenitiesByCategory> getAmenitiesGrouped(String categories) async {
    final amenities = await getAmenities(categories);
    return AmenitiesByCategory.fromList(amenities);
  }
}
