import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/property_service.dart';

// ─── Estado de favoritos ───────────────────────────────────────────

class FavoritesState {
  /// IDs de propiedades favoritas (fuente única de verdad).
  final Set<String> favoriteIds;

  /// Lista completa de propiedades favoritas (para la pantalla Favoritos).
  final List<SearchPropertyModel> favorites;

  final bool isLoadingIds;
  final bool isLoadingList;

  /// ID de la propiedad que se está procesando (add/remove en curso).
  final String? togglingId;

  final String? error;

  const FavoritesState({
    this.favoriteIds = const {},
    this.favorites = const [],
    this.isLoadingIds = false,
    this.isLoadingList = false,
    this.togglingId,
    this.error,
  });

  bool isFavorite(String propertyId) => favoriteIds.contains(propertyId);

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    List<SearchPropertyModel>? favorites,
    bool? isLoadingIds,
    bool? isLoadingList,
    String? togglingId,
    String? error,
    bool clearTogglingId = false,
    bool clearError = false,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favorites: favorites ?? this.favorites,
      isLoadingIds: isLoadingIds ?? this.isLoadingIds,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      togglingId: clearTogglingId ? null : (togglingId ?? this.togglingId),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Notifier ──────────────────────────────────────────────────────

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final PropertyService _service;

  FavoritesNotifier(this._service) : super(const FavoritesState());

  /// Carga solo los IDs de favoritos (para pintar corazones en home).
  Future<void> loadFavoriteIds() async {
    state = state.copyWith(isLoadingIds: true, clearError: true);
    try {
      final ids = await _service.getFavoriteIds();
      state = state.copyWith(
        favoriteIds: ids.toSet(),
        isLoadingIds: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingIds: false,
        error: e.toString(),
      );
    }
  }

  /// Carga la lista completa de favoritos (para la pantalla Favoritos).
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoadingList: true, clearError: true);
    try {
      final list = await _service.getFavorites();
      state = state.copyWith(
        favorites: list,
        favoriteIds: list.map((p) => p.propertyId).toSet(),
        isLoadingList: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingList: false,
        error: e.toString(),
      );
    }
  }

  /// Alterna favorito: agrega si no existe, quita si ya existe.
  /// Retorna `true` si la operación fue exitosa.
  Future<bool> toggleFavorite(String propertyId) async {
    if (state.togglingId != null) return false; // ya hay uno en curso

    final wasFavorite = state.isFavorite(propertyId);
    state = state.copyWith(togglingId: propertyId);

    // Actualización optimista: cambiar estado inmediatamente.
    final updatedIds = Set<String>.from(state.favoriteIds);
    if (wasFavorite) {
      updatedIds.remove(propertyId);
    } else {
      updatedIds.add(propertyId);
    }
    state = state.copyWith(favoriteIds: updatedIds);

    try {
      if (wasFavorite) {
        await _service.removeFavorite(propertyId);
        // Quitar de la lista completa si estaba cargada.
        final updatedList = state.favorites
            .where((p) => p.propertyId != propertyId)
            .toList();
        state = state.copyWith(
          favorites: updatedList,
          clearTogglingId: true,
        );
      } else {
        await _service.addFavorite(propertyId);
        state = state.copyWith(clearTogglingId: true);
      }
      return true;
    } catch (e) {
      // Revertir cambio optimista.
      final revertedIds = Set<String>.from(state.favoriteIds);
      if (wasFavorite) {
        revertedIds.add(propertyId);
      } else {
        revertedIds.remove(propertyId);
      }
      state = state.copyWith(
        favoriteIds: revertedIds,
        clearTogglingId: true,
        error: e.toString(),
      );
      return false;
    }
  }
}

// ─── Provider ──────────────────────────────────────────────────────

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final service = ref.read(propertyServiceProvider);
  return FavoritesNotifier(service);
});
