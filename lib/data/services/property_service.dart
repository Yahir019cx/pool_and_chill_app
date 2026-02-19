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

  // ─── BOOKING / CALENDARIO ─────────────────────────────────────

  /// Obtiene el calendario de disponibilidad (POST /booking/calendar).
  Future<CalendarAvailabilityResponse> getBookingCalendar(
      String propertyId) async {
    final response = await _apiClient.post(
      ApiRoutes.bookingCalendar,
      body: {'propertyId': propertyId},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CalendarAvailabilityResponse.fromJson(json);
    }

    throw Exception(
      'Error al obtener calendario: ${response.statusCode}',
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
      ApiRoutes.removeFavorite,
      body: {'propertyId': propertyId},
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

  // ─── ACTUALIZACIÓN DE PROPIEDAD (HOST) ────────────────────────

  /// Actualiza descripción y/o precios/horarios (PATCH /properties/update/basic-info).
  /// [data] debe tener al menos un campo: description, pool, cabin o camping.
  Future<UpdateResponse> updateBasicInfo(
    String propertyId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch(
      ApiRoutes.updateBasicInfo,
      body: {'propertyId': propertyId, 'data': data},
    );
    return _parseUpdateResponse(response, 'Error al actualizar información básica');
  }

  /// Actualiza capacidad, temperatura y amenidades de la alberca.
  Future<UpdateResponse> updatePoolAmenities({
    required String propertyId,
    required int maxPersons,
    double? temperatureMin,
    double? temperatureMax,
    List<AmenityItemRequest>? items,
  }) async {
    final body = <String, dynamic>{
      'propertyId': propertyId,
      'maxPersons': maxPersons,
      if (temperatureMin != null) 'temperatureMin': temperatureMin,
      if (temperatureMax != null) 'temperatureMax': temperatureMax,
      if (items != null) 'items': items.map((e) => e.toJson()).toList(),
    };
    final response = await _apiClient.patch(ApiRoutes.updatePoolAmenities, body: body);
    return _parseUpdateResponse(response, 'Error al actualizar amenidades de alberca');
  }

  /// Actualiza capacidad, habitaciones, camas, baños y amenidades de cabaña.
  Future<UpdateResponse> updateCabinAmenities({
    required String propertyId,
    required int maxGuests,
    required int bedrooms,
    required int singleBeds,
    required int doubleBeds,
    required int fullBathrooms,
    int? halfBathrooms,
    List<AmenityItemRequest>? items,
  }) async {
    final body = <String, dynamic>{
      'propertyId': propertyId,
      'maxGuests': maxGuests,
      'bedrooms': bedrooms,
      'singleBeds': singleBeds,
      'doubleBeds': doubleBeds,
      'fullBathrooms': fullBathrooms,
      if (halfBathrooms != null) 'halfBathrooms': halfBathrooms,
      if (items != null) 'items': items.map((e) => e.toJson()).toList(),
    };
    final response = await _apiClient.patch(ApiRoutes.updateCabinAmenities, body: body);
    return _parseUpdateResponse(response, 'Error al actualizar amenidades de cabaña');
  }

  /// Actualiza capacidad, área, tiendas y amenidades del camping.
  Future<UpdateResponse> updateCampingAmenities({
    required String propertyId,
    required int maxPersons,
    required double areaSquareMeters,
    required int approxTents,
    List<AmenityItemRequest>? items,
  }) async {
    final body = <String, dynamic>{
      'propertyId': propertyId,
      'maxPersons': maxPersons,
      'areaSquareMeters': areaSquareMeters,
      'approxTents': approxTents,
      if (items != null) 'items': items.map((e) => e.toJson()).toList(),
    };
    final response = await _apiClient.patch(ApiRoutes.updateCampingAmenities, body: body);
    return _parseUpdateResponse(response, 'Error al actualizar amenidades de camping');
  }

  /// Reemplaza todas las reglas activas de la propiedad.
  Future<UpdateResponse> updateRules({
    required String propertyId,
    required List<PropertyRuleRequest> rules,
  }) async {
    final response = await _apiClient.patch(
      ApiRoutes.updateRules,
      body: {
        'propertyId': propertyId,
        'rules': rules.map((r) => r.toJson()).toList(),
      },
    );
    return _parseUpdateResponse(response, 'Error al actualizar reglas');
  }

  /// Agrega una imagen a la propiedad (POST /properties/update/images).
  Future<AddImageResponse> addPropertyImage({
    required String propertyId,
    required String imageUrl,
    bool isPrimary = false,
  }) async {
    final response = await _apiClient.post(
      ApiRoutes.updateImages,
      body: {
        'propertyId': propertyId,
        'imageUrl': imageUrl,
        'isPrimary': isPrimary,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AddImageResponse.fromJson(json);
    }
    throw Exception(_extractMessage(response, 'Error al agregar imagen'));
  }

  /// Elimina una imagen de la propiedad (DELETE con body).
  Future<void> deletePropertyImage({
    required String propertyId,
    required String propertyImageId,
  }) async {
    final response = await _apiClient.deleteWithBody(
      ApiRoutes.updateImages,
      body: {'propertyId': propertyId, 'propertyImageId': propertyImageId},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractMessage(response, 'Error al eliminar imagen'));
    }
  }

  /// Cambia el estado de la propiedad entre activa (3) y pausada (4).
  Future<void> updatePropertyStatus({
    required String propertyId,
    required int status,
  }) async {
    final response = await _apiClient.post(
      ApiRoutes.ownerStatus,
      body: {'propertyId': propertyId, 'status': status},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          _extractMessage(response, 'Error al cambiar estado de la propiedad'));
    }
  }

  // ─── Helpers privados ──────────────────────────────────────────

  UpdateResponse _parseUpdateResponse(dynamic response, String fallback) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UpdateResponse.fromJson(json);
    }
    throw Exception(_extractMessage(response, fallback));
  }

  String _extractMessage(dynamic response, String fallback) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['message'] != null) {
        return json['message'] is List
            ? (json['message'] as List).join('\n')
            : json['message'].toString();
      }
    } catch (_) {}
    if (response.statusCode == 403) return 'No tienes permiso para editar esta propiedad';
    if (response.statusCode == 401) return 'Sesión expirada. Por favor, inicia sesión de nuevo.';
    return '$fallback (${response.statusCode})';
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
