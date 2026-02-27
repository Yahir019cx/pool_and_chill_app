import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

// ─── State ─────────────────────────────────────────────────────────

class HostReservasState {
  final bool isLoading;
  final List<HostBooking> bookings;
  final BookingsSummary? summary;
  final String? error;

  const HostReservasState({
    this.isLoading = false,
    this.bookings = const [],
    this.summary,
    this.error,
  });

  HostReservasState copyWith({
    bool? isLoading,
    List<HostBooking>? bookings,
    BookingsSummary? summary,
    String? error,
    bool clearError = false,
  }) {
    return HostReservasState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      summary: summary ?? this.summary,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Reservas confirmadas (status 2) — las que aparecen en "Próximas reservas".
  List<HostBooking> get proximas =>
      bookings.where((b) => b.status.id == 2).toList();

  /// Suma de todos los payouts (ganancias totales).
  double get totalGanancias =>
      bookings.fold(0.0, (sum, b) => sum + b.payout.hostPayout);

  /// Rating del host. Toma el primero con reseñas; si ninguno tiene, el primero.
  GuestBookingRating? get hostRating {
    if (bookings.isEmpty) return null;
    final withReviews =
        bookings.where((b) => b.hostRating.totalReviews > 0);
    return withReviews.isNotEmpty
        ? withReviews.first.hostRating
        : bookings.first.hostRating;
  }
}

// ─── Notifier ──────────────────────────────────────────────────────

class HostReservasNotifier extends StateNotifier<HostReservasState> {
  final BookingService _service;

  HostReservasNotifier(this._service) : super(const HostReservasState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getHostBookings();
      state = state.copyWith(
        isLoading: false,
        bookings: result.data.bookings,
        summary: result.data.summary,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ─── Provider ──────────────────────────────────────────────────────

final hostReservasProvider =
    StateNotifierProvider<HostReservasNotifier, HostReservasState>((ref) {
  final service = ref.read(bookingServiceProvider);
  return HostReservasNotifier(service);
});
