import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_search_provider.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/providers/favorites_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/advanced_filters_button.dart';
import '../widgets/espacios_list_widget.dart';
import '../../properties/Screens/property_detail_screen.dart';

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  late final ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga inicial de propiedades.
      ref.read(propertySearchProvider.notifier).search();

      // Cargar IDs de favoritos si el usuario está logueado.
      final auth =
          provider_pkg.Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        ref.read(favoritesProvider.notifier).loadFavoriteIds();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Detecta cuando el usuario se acerca al final de la lista.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(propertySearchProvider.notifier).loadMore();
    }
  }

  /// Debounce de búsqueda por texto (500 ms).
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(propertySearchProvider.notifier).setSearchQuery(value);
    });
  }

  /// Toggle de un chip de tipo.
  void _onChipToggle(int index) {
    ref.read(propertySearchProvider.notifier).toggleChipFilter(index);
  }

  /// Al aplicar filtros avanzados (ubicación, precio, orden).
  void _onAdvancedFiltersApply(AdvancedFilterValues values) {
    ref.read(propertySearchProvider.notifier).applyAdvancedFilters(
          stateId: values.stateId,
          cityId: values.cityId,
          minPrice: values.minPrice,
          maxPrice: values.maxPrice,
          sortBy: values.sortBy,
        );
  }

  /// Al limpiar todos los filtros.
  void _onClearAll() {
    ref.read(propertySearchProvider.notifier).clearAllFilters();
  }

  /// Abrir detalle de propiedad.
  void _onPropertyTap(String propertyId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailScreen(propertyId: propertyId),
      ),
    );
  }

  /// Toggle favorito desde una card.
  void _onFavoriteToggle(String propertyId) {
    final auth =
        provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      TopChip.showInfo(context, 'Inicia sesión para guardar favoritos');
      return;
    }
    ref.read(favoritesProvider.notifier).toggleFavorite(propertyId);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(propertySearchProvider);
    final favState = ref.watch(favoritesProvider);
    final filters = searchState.filters;

    // Determinar chip seleccionado.
    int? selectedChip;
    if (filters.hasCabin == true) {
      selectedChip = 0;
    } else if (filters.hasPool == true) {
      selectedChip = 1;
    } else if (filters.hasCamping == true) {
      selectedChip = 2;
    }

    final advancedValues = AdvancedFilterValues(
      stateId: filters.stateId,
      cityId: filters.cityId,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      sortBy: filters.sortBy,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBarWidget(
          onChanged: _onSearchChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AdvancedFiltersButton(
            currentFilters: advancedValues,
            hasActiveFilters:
                advancedValues.hasActiveFilters || selectedChip != null,
            onApply: _onAdvancedFiltersApply,
            onClear: _onClearAll,
          ),
        ),
        FilterChipsWidget(
          selectedIndex: selectedChip,
          onSelected: _onChipToggle,
        ),
        Expanded(
          child: EspaciosListWidget(
            properties: searchState.properties,
            scrollController: _scrollController,
            isLoading: searchState.isLoading,
            isLoadingMore: searchState.isLoadingMore,
            error: searchState.error,
            favoriteIds: favState.favoriteIds,
            onFavoriteToggle: _onFavoriteToggle,
            onPropertyTap: _onPropertyTap,
          ),
        ),
      ],
    );
  }
}
