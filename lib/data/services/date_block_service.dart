import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/date_block_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class DateBlockService {
  final ApiClient _client;

  DateBlockService(this._client);

  Future<void> createDateBlock(CreateDateBlockRequest req) async {
    final response = await _client.post(
      ApiRoutes.dateBlocks,
      body: req.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_msg(response, 'Error al bloquear las fechas'));
    }
  }

  Future<void> deleteDateBlock(DeleteDateBlockRequest req) async {
    final response = await _client.deleteWithBody(
      ApiRoutes.dateBlocks,
      body: req.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_msg(response, 'Error al desbloquear las fechas'));
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

final dateBlockServiceProvider = Provider<DateBlockService>((ref) {
  return DateBlockService(ref.read(apiClientProvider));
});
