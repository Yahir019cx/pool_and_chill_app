import 'dart:convert';
import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';

class PropertyService {
  final ApiClient _apiClient;

  PropertyService(this._apiClient);

  /// Crea una propiedad (POST /properties). Body según contrato del backend.
  /// 201: devuelve PublishPropertyResponse con propertyId.
  /// 400/401/500: lanza Exception con mensaje para mostrar al usuario.
  Future<PublishPropertyResponse> createProperty(PublishPropertyBody body) async {
    final response = await _apiClient.post(
      ApiRoutes.properties,
      body: body.toJson(),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PublishPropertyResponse.fromJson(json);
    }

    String message = 'Error al crear la propiedad';
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['message'] != null) {
        message = json['message'] is List
            ? (json['message'] as List).join('\n')
            : json['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  /// Busca propiedades con filtros y paginación.
  Future<SearchPropertiesResponse> searchProperties({
    bool? hasPool,
    bool? hasCabin,
    bool? hasCamping,
    int? stateId,
    int? cityId,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? amenities,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    if (hasPool == true) params['hasPool'] = 'true';
    if (hasCabin == true) params['hasCabin'] = 'true';
    if (hasCamping == true) params['hasCamping'] = 'true';
    if (stateId != null) params['stateId'] = stateId.toString();
    if (cityId != null) params['cityId'] = cityId.toString();
    if (minPrice != null) params['minPrice'] = minPrice.toStringAsFixed(0);
    if (maxPrice != null) params['maxPrice'] = maxPrice.toStringAsFixed(0);
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (amenities != null && amenities.isNotEmpty) {
      params['amenities'] = amenities;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sortBy'] = sortBy;
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final path = '${ApiRoutes.searchProperties}?$queryString';

    final response = await _apiClient.get(path, withAuth: false);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SearchPropertiesResponse.fromJson(json);
    }

    throw Exception(
      'Error al buscar propiedades: ${response.statusCode}',
    );
  }

  /// Obtiene el detalle de una propiedad por ID (POST /properties/by-id).
  Future<PropertyDetailResponse> getPropertyById(String propertyId) async {
    final response = await _apiClient.post(
      ApiRoutes.propertyById,
      body: {'propertyId': propertyId},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) {
        throw Exception('Error al obtener el detalle de la propiedad');
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return PropertyDetailResponse.fromJson(data);
    }

    throw Exception(
      'Error al obtener detalle: ${response.statusCode}',
    );
  }

  // ─── FAVORITOS ──────────────────────────────────────────────────

  /// Obtiene solo los IDs de propiedades favoritas del usuario.
  Future<List<String>> getFavoriteIds() async {
    final response = await _apiClient.get(ApiRoutes.favoriteIds);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final List<dynamic> ids = data['propertyIds'] ?? [];
      return ids.map((e) => e.toString()).toList();
    }

    throw Exception('Error al obtener favoritos: ${response.statusCode}');
  }

  /// Obtiene la lista completa de propiedades favoritas.
  Future<List<SearchPropertyModel>> getFavorites() async {
    final response = await _apiClient.get(ApiRoutes.favorites);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>? ?? {};
      final List<dynamic> properties = data['properties'] ?? [];
      return properties
          .map((e) =>
              SearchPropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al obtener favoritos: ${response.statusCode}');
  }

  /// Agrega una propiedad a favoritos.
  Future<void> addFavorite(String propertyId) async {
    final response = await _apiClient.post(
      ApiRoutes.favorites,
      body: {'propertyId': propertyId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar favorito: ${response.statusCode}');
    }
  }

  /// Quita una propiedad de favoritos.
  Future<void> removeFavorite(String propertyId) async {
    final response = await _apiClient.delete(
      ApiRoutes.removeFavorite(propertyId),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al quitar favorito: ${response.statusCode}');
    }
  }

  // ─── AMENIDADES ────────────────────────────────────────────────

  /// Obtiene el catálogo de amenidades (GET /catalogs/amenities?category=...).
  /// Público, no requiere auth. [categories] ej: "pool", "pool,cabin", "pool,cabin,camping".
  Future<List<AmenityModel>> getAmenities(String categories) async {
    final path = categories.trim().isEmpty
        ? ApiRoutes.catalogAmenities
        : ApiRoutes.amenitiesByCategory(categories);
    final response = await _apiClient.get(path, withAuth: false);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => AmenityModel.fromJson(item as Map<String, dynamic>)).toList();
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
