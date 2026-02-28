import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

// ─── State ─────────────────────────────────────────────────────────

class HostReservasState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<HostBooking> bookings;
  final BookingsSummary? summary;
  final String? error;
  final bool hasMore;

  const HostReservasState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.bookings = const [],
    this.summary,
    this.error,
    this.hasMore = false,
  });

  HostReservasState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<HostBooking>? bookings,
    BookingsSummary? summary,
    String? error,
    bool? hasMore,
    bool clearError = false,
  }) {
    return HostReservasState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      bookings: bookings ?? this.bookings,
      summary: summary ?? this.summary,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
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
  HostReservasNotifier(this._service) : super(const HostReservasState());

  static const int _pageSize = 20;
  final BookingService _service;

  int get _nextPage =>
      (state.bookings.length / _pageSize).ceil() + 1;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getHostBookings(page: 1);
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
    final nextPage = _nextPage;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _service.getHostBookings(page: nextPage);
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
}

// ─── Provider ──────────────────────────────────────────────────────

final hostReservasProvider =
    StateNotifierProvider<HostReservasNotifier, HostReservasState>((ref) {
  final service = ref.read(bookingServiceProvider);
  return HostReservasNotifier(service);
});
