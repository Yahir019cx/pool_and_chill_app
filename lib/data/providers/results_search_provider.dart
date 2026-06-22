import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_search_provider.dart';

/// Provider independiente para la pantalla de resultados de búsqueda.
/// Usa la misma lógica que [propertySearchProvider] pero en una instancia
/// separada para no contaminar el estado del Home.
final resultsSearchProvider =
    StateNotifierProvider<PropertySearchNotifier, PropertySearchState>((ref) {
  final service = ref.read(propertyServiceProvider);
  return PropertySearchNotifier(service);
});
