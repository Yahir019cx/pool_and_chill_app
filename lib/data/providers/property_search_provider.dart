import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/property_service.dart';

// ─── Filtros de búsqueda ───────────────────────────────────────────

class PropertySearchFilters {
  final bool? hasPool;
  final bool? hasCabin;
  final bool? hasCamping;
  final int? stateId;
  final int? cityId;
  final double? minPrice;
  final double? maxPrice;
  final String? search;
  final String? amenities;
  final String? sortBy;

  const PropertySearchFilters({
    this.hasPool,
    this.hasCabin,
    this.hasCamping,
    this.stateId,
    this.cityId,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.amenities,
    this.sortBy,
  });

  PropertySearchFilters copyWith({
    bool? hasPool,
    bool? hasCabin,
    bool? hasCamping,
    int? stateId,
    int? cityId,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? amenities,
    String? sortBy,
    bool clearHasPool = false,
    bool clearHasCabin = false,
    bool clearHasCamping = false,
    bool clearStateId = false,
    bool clearCityId = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearSearch = false,
    bool clearAmenities = false,
    bool clearSortBy = false,
  }) {
    return PropertySearchFilters(
      hasPool: clearHasPool ? null : (hasPool ?? this.hasPool),
      hasCabin: clearHasCabin ? null : (hasCabin ?? this.hasCabin),
      hasCamping: clearHasCamping ? null : (hasCamping ?? this.hasCamping),
      stateId: clearStateId ? null : (stateId ?? this.stateId),
      cityId: clearCityId ? null : (cityId ?? this.cityId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      search: clearSearch ? null : (search ?? this.search),
      amenities: clearAmenities ? null : (amenities ?? this.amenities),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
    );
  }

  /// `true` si hay al menos un filtro avanzado activo (precio, orden, etc.).
  bool get hasAdvancedFilters =>
      minPrice != null ||
      maxPrice != null ||
      sortBy != null ||
      stateId != null ||
      cityId != null ||
      amenities != null;

  /// `true` si hay cualquier filtro activo (chips, búsqueda, avanzados).
  bool get hasAnyFilter =>
      hasPool != null ||
      hasCabin != null ||
      hasCamping != null ||
      (search != null && search!.isNotEmpty) ||
      hasAdvancedFilters;
}

// ─── Estado de la búsqueda ─────────────────────────────────────────

class PropertySearchState {
  final List<SearchPropertyModel> properties;
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PropertySearchFilters filters;

  const PropertySearchState({
    this.properties = const [],
    this.currentPage = 1,
    this.totalCount = 0,
    this.pageSize = 20,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filters = const PropertySearchFilters(),
  });

  PropertySearchState copyWith({
    List<SearchPropertyModel>? properties,
    int? currentPage,
    int? totalCount,
    int? pageSize,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PropertySearchFilters? filters,
    bool clearError = false,
  }) {
    return PropertySearchState(
      properties: properties ?? this.properties,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      filters: filters ?? this.filters,
    );
  }
}

// ─── Notifier ──────────────────────────────────────────────────────

class PropertySearchNotifier extends StateNotifier<PropertySearchState> {
  final PropertyService _service;

  PropertySearchNotifier(this._service) : super(const PropertySearchState());

  /// Primera carga o refresh: page=1, reemplaza la lista. Load more: siguiente página, concatena data.properties. Para cuando data.hasMore === false.
  Future<void> search({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        properties: [],
        hasMore: false,
        clearError: true,
      );
    } else {
      if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      final page = reset ? 1 : state.currentPage + 1;
      final f = state.filters;

      final response = await _service.searchProperties(
        hasPool: f.hasPool,
        hasCabin: f.hasCabin,
        hasCamping: f.hasCamping,
        stateId: f.stateId,
        cityId: f.cityId,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        search: f.search,
        amenities: f.amenities,
        sortBy: f.sortBy,
        page: page,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        properties: reset
            ? response.properties
            : [...state.properties, ...response.properties],
        currentPage: response.page,
        totalCount: response.totalCount,
        hasMore: response.hasMore,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Carga la siguiente página (scroll infinito).
  void loadMore() => search(reset: false);

  /// Actualiza todos los filtros y relanza búsqueda desde página 1.
  void updateFilters(PropertySearchFilters filters) {
    state = state.copyWith(filters: filters);
    search();
  }

  /// Actualiza el texto de búsqueda y relanza.
  void setSearchQuery(String query) {
    final newFilters = query.isEmpty
        ? state.filters.copyWith(clearSearch: true)
        : PropertySearchFilters(
            hasPool: state.filters.hasPool,
            hasCabin: state.filters.hasCabin,
            hasCamping: state.filters.hasCamping,
            stateId: state.filters.stateId,
            cityId: state.filters.cityId,
            minPrice: state.filters.minPrice,
            maxPrice: state.filters.maxPrice,
            search: query,
            amenities: state.filters.amenities,
            sortBy: state.filters.sortBy,
          );
    state = state.copyWith(filters: newFilters);
    search();
  }

  /// Alterna un chip de tipo (selección individual: uno a la vez).
  /// Si el chip ya estaba seleccionado, lo deselecciona.
  void toggleChipFilter(int chipIndex) {
    final f = state.filters;

    // Determinar si el chip actual ya está activo.
    final isActive = switch (chipIndex) {
      0 => f.hasCabin == true,
      1 => f.hasPool == true,
      2 => f.hasCamping == true,
      _ => false,
    };

    // Populares — sin lógica de backend por ahora.
    if (chipIndex == 3) return;

    // Si ya estaba activo → deseleccionar; si no → seleccionar solo este.
    final newFilters = PropertySearchFilters(
      hasPool: (!isActive && chipIndex == 1) ? true : null,
      hasCabin: (!isActive && chipIndex == 0) ? true : null,
      hasCamping: (!isActive && chipIndex == 2) ? true : null,
      stateId: f.stateId,
      cityId: f.cityId,
      minPrice: f.minPrice,
      maxPrice: f.maxPrice,
      search: f.search,
      amenities: f.amenities,
      sortBy: f.sortBy,
    );

    state = state.copyWith(filters: newFilters);
    search();
  }

  /// Actualiza filtros avanzados: ubicación (stateId, cityId), precio (min/max) y orden (sortBy).
  void applyAdvancedFilters({
    int? stateId,
    int? cityId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    final f = state.filters;
    final newFilters = PropertySearchFilters(
      hasPool: f.hasPool,
      hasCabin: f.hasCabin,
      hasCamping: f.hasCamping,
      stateId: stateId,
      cityId: cityId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      search: f.search,
      amenities: f.amenities,
      sortBy: sortBy,
    );
    state = state.copyWith(filters: newFilters);
    search();
  }

  /// Ordenar resultados: price_asc (más baratos), price_desc (más caros), rating (mejor rating).
  void setSortBy(String? sortBy) {
    final f = state.filters;
    state = state.copyWith(
      filters: PropertySearchFilters(
        hasPool: f.hasPool,
        hasCabin: f.hasCabin,
        hasCamping: f.hasCamping,
        stateId: f.stateId,
        cityId: f.cityId,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        search: f.search,
        amenities: f.amenities,
        sortBy: sortBy,
      ),
    );
    search();
  }

  /// Limpia todos los filtros y relanza búsqueda.
  void clearAllFilters() {
    state = state.copyWith(filters: const PropertySearchFilters());
    search();
  }
}

// ─── Provider ──────────────────────────────────────────────────────

final propertySearchProvider =
    StateNotifierProvider<PropertySearchNotifier, PropertySearchState>((ref) {
  final service = ref.read(propertyServiceProvider);
  return PropertySearchNotifier(service);
});
