import 'dart:convert';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  /// POST /booking/create → crea la reserva y retorna el clientSecret de Stripe.
  Future<CreateBookingResponse> createBooking(
      CreateBookingRequest request) async {
    final response = await _apiClient.post(
      ApiRoutes.bookingCreate,
      body: request.toJson(),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CreateBookingResponse.fromJson(json);
    }

    String message = 'Error al crear la reserva';
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
}
