import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

enum RentaFilter { proximas, pasadas, canceladas }

// ─── State ─────────────────────────────────────────────────────────

class RentasState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<GuestBooking> bookings;
  final BookingsSummary? summary;
  final String? error;
  final RentaFilter filter;
  final bool hasMore;

  const RentasState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.bookings = const [],
    this.summary,
    this.error,
    this.filter = RentaFilter.proximas,
    this.hasMore = false,
  });

  RentasState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<GuestBooking>? bookings,
    BookingsSummary? summary,
    String? error,
    bool? hasMore,
    bool clearError = false,
    RentaFilter? filter,
  }) {
    return RentasState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      bookings: bookings ?? this.bookings,
      summary: summary ?? this.summary,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
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
  RentasNotifier(this._service) : super(const RentasState());

  static const int _pageSize = 20;
  final BookingService _service;

  int get _nextPage =>
      (state.bookings.length / _pageSize).ceil() + 1;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getGuestBookings(page: 1);
      state = state.copyWith(
        isLoading: false,
        bookings: result.data.bookings,
        summary: result.data.summary,
        hasMore: result.data.pagination.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _service.getGuestBookings(page: _nextPage);
      state = state.copyWith(
        isLoadingMore: false,
        bookings: [...state.bookings, ...result.data.bookings],
        summary: result.data.summary,
        hasMore: result.data.pagination.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
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
