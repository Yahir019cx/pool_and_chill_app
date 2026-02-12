import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/data/models/property/search_property_model.dart';
import 'card_espacio.dart';

class EspaciosListWidget extends StatelessWidget {
  final List<SearchPropertyModel> properties;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  /// IDs de propiedades favoritas para pintar el corazón.
  final Set<String> favoriteIds;

  /// Callback al pulsar el corazón en una card.
  final ValueChanged<String>? onFavoriteToggle;

  /// Callback al tocar una card (abrir detalle). Si es null no se navega.
  final ValueChanged<String>? onPropertyTap;

  const EspaciosListWidget({
    super.key,
    required this.properties,
    required this.scrollController,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.favoriteIds = const {},
    this.onFavoriteToggle,
    this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Estado de carga inicial
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
            color: Color(0xFF3CA2A2),
          ),
        ),
      );
    }

    // Estado de error
    if (error != null && properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Ocurrió un error al cargar los espacios',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Estado vacío
    if (properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'No se encontraron espacios con los filtros seleccionados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Lista con scroll infinito
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: properties.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        // Indicador de carga al final
        if (index == properties.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3CA2A2),
              ),
            ),
          );
        }

        final property = properties[index];
        return EspacioCard(
          property: property,
          isFavorite: favoriteIds.contains(property.propertyId),
          onFavoriteToggle: onFavoriteToggle,
          onTap: onPropertyTap,
        );
      },
    );
  }
}
