import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

enum RentaFilter { proximas, pasadas, canceladas }

// ─── State ─────────────────────────────────────────────────────────

class RentasState {
  final bool isLoading;
  final List<GuestBooking> bookings;
  final String? error;
  final RentaFilter filter;

  const RentasState({
    this.isLoading = false,
    this.bookings = const [],
    this.error,
    this.filter = RentaFilter.proximas,
  });

  RentasState copyWith({
    bool? isLoading,
    List<GuestBooking>? bookings,
    String? error,
    bool clearError = false,
    RentaFilter? filter,
  }) {
    return RentasState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
    );
  }

  List<GuestBooking> get filtered {
    switch (filter) {
      case RentaFilter.proximas:
        return bookings.where((b) => b.status.id == 2).toList();
      case RentaFilter.pasadas:
        return bookings.where((b) => b.status.id == 4).toList();
      case RentaFilter.canceladas:
        return bookings.where((b) => b.status.id == 5 || b.status.id == 6).toList();
    }
  }

  /// Calificación del guest. Todos los bookings comparten la misma, se toma
  /// del primero que tenga reseñas; si ninguno tiene, del primero disponible.
  GuestBookingRating? get guestRating {
    if (bookings.isEmpty) return null;
    final withReviews = bookings.where((b) => b.guestRating.totalReviews > 0);
    return withReviews.isNotEmpty
        ? withReviews.first.guestRating
        : bookings.first.guestRating;
  }
}

// ─── Notifier ──────────────────────────────────────────────────────

class RentasNotifier extends StateNotifier<RentasState> {
  final BookingService _service;

  RentasNotifier(this._service) : super(const RentasState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getGuestBookings();
      state = state.copyWith(isLoading: false, bookings: result.data.bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(RentaFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

// ─── Provider ──────────────────────────────────────────────────────

final rentasProvider = StateNotifierProvider<RentasNotifier, RentasState>((ref) {
  final service = ref.read(bookingServiceProvider);
  return RentasNotifier(service);
});
