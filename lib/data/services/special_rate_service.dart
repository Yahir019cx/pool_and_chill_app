import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/special_rate_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class SpecialRateService {
  final ApiClient _client;

  SpecialRateService(this._client);

  Future<void> createSpecialRate(CreateSpecialRateRequest req) async {
    final response = await _client.post(
      ApiRoutes.specialRate,
      body: req.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_msg(response, 'Error al crear la tarifa especial'));
    }
  }

  Future<void> deactivateSpecialRate(
    String idSpecialRate, {
    String? propertyId,
  }) async {
    final response = await _client.post(
      ApiRoutes.specialRateDeactivate,
      body: {
        'idSpecialRate': idSpecialRate,
        if (propertyId != null) 'propertyId': propertyId,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_msg(response, 'Error al desactivar la tarifa'));
    }
  }

  String _msg(dynamic response, String fallback) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['message'] != null) {
        return json['message'] is List
            ? (json['message'] as List).join('\n')
            : json['message'].toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }
}

final specialRateServiceProvider = Provider<SpecialRateService>((ref) {
  return SpecialRateService(ref.read(apiClientProvider));
});
