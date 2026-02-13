import 'dart:convert';
import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/catalog_model.dart';

class CatalogService {
  final ApiClient _api;

  CatalogService(this._api);

  /// GET /catalogs/states — catálogo de estados (público, auth opcional).
  Future<List<StateCatalogItem>> getStates() async {
    final response = await _api.get(ApiRoutes.catalogStates);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar estados: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => StateCatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /catalogs/cities/:stateId — ciudades por estado.
  Future<List<CityCatalogItem>> getCities(int stateId) async {
    final response = await _api.get(ApiRoutes.catalogCities(stateId));

    if (response.statusCode != 200) {
      throw Exception('Error al cargar ciudades: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CityCatalogItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
