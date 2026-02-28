import 'dart:convert';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/api/api_routes.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  static const int _defaultPageSize = 20;

  /// POST /booking/host/bookings → reservas del host con paginación.
  /// Body opcional: { "page": number, "pageSize": number }. Por defecto page=1, pageSize=20.
  Future<HostBookingsResponse> getHostBookings({
    int page = 1,
    int pageSize = _defaultPageSize,
  }) async {
    final body = <String, dynamic>{
      'page': page,
      'pageSize': pageSize.clamp(1, 100),
    };
    final response = await _apiClient.post(
      ApiRoutes.hostBookings,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return HostBookingsResponse.fromJson(json);
    }

    String message = 'Error al obtener las reservas';
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

  /// POST /booking/guest/bookings → reservas del guest con paginación.
  /// Body opcional: { "page": number, "pageSize": number }. Por defecto page=1, pageSize=20.
  Future<GuestBookingsResponse> getGuestBookings({
    int page = 1,
    int pageSize = _defaultPageSize,
  }) async {
    final body = <String, dynamic>{
      'page': page,
      'pageSize': pageSize.clamp(1, 100),
    };
    final response = await _apiClient.post(
      ApiRoutes.guestBookings,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GuestBookingsResponse.fromJson(json);
    }

    String message = 'Error al obtener tus rentas';
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

  /// POST /booking/guest/review → el host califica al huésped.
  Future<void> reviewGuest(GuestReviewRequest request) async {
    final response = await _apiClient.post(
      ApiRoutes.bookingGuestReview,
      body: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    String message = 'Error al enviar la reseña del huésped';
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

  /// POST /booking/property/review → el guest califica la propiedad (reserva pasada).
  Future<void> submitPropertyReview(PropertyReviewRequest request) async {
    final response = await _apiClient.post(
      ApiRoutes.bookingPropertyReview,
      body: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    String message = 'Error al enviar la calificación de la propiedad';
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

  /// POST /booking/host/review → el guest califica al host (después de calificar propiedad).
  Future<void> submitHostReview(HostReviewRequest request) async {
    final response = await _apiClient.post(
      ApiRoutes.bookingHostReview,
      body: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    String message = 'Error al enviar la calificación del anfitrión';
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
