import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/services/property_service.dart';

/// Provider para el ApiClient (se sobreescribe en main.dart)
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider debe ser sobreescrito');
});

/// Provider para el servicio de propiedades
final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PropertyService(apiClient);
});

/// Provider para las amenidades del catálogo
final amenitiesProvider = FutureProvider.family<List<AmenityModel>, String>((ref, categories) async {
  final service = ref.read(propertyServiceProvider);
  return service.getAmenities(categories);
});

/// Notifier para el estado del registro de propiedad
class PropertyRegistrationNotifier extends StateNotifier<PropertyRegistrationState> {
  PropertyRegistrationNotifier() : super(const PropertyRegistrationState());

  /// Reinicia el estado completo
  void reset() {
    state = const PropertyRegistrationState();
  }

  /// Step 1: Tipos de espacio
  void setTiposEspacio(Set<String> tipos) {
    state = state.copyWith(tiposEspacioSeleccionados: tipos);
  }

  void toggleTipoEspacio(String tipo) {
    final current = Set<String>.from(state.tiposEspacioSeleccionados);
    if (current.contains(tipo)) {
      current.remove(tipo);
    } else {
      current.add(tipo);
    }
    state = state.copyWith(tiposEspacioSeleccionados: current);
  }

  /// Step 2: Dirección
  void setAddressData(AddressData data) {
    state = state.copyWith(addressData: data);
  }

  void setLocation(double lat, double lng) {
    final current = state.addressData ?? const AddressData();
    state = state.copyWith(addressData: current.copyWith(lat: lat, lng: lng));
  }

  /// Step 3: Specs de Cabaña
  void setCabanaSpecs(CabanaSpecs specs) {
    state = state.copyWith(cabana: specs);
  }

  void updateCabanaCounter(String field, int value) {
    final c = state.cabana;
    state = state.copyWith(
      cabana: switch (field) {
        'huespedes' => c.copyWith(huespedes: value),
        'recamaras' => c.copyWith(recamaras: value),
        'camasIndividuales' => c.copyWith(camasIndividuales: value),
        'camasMatrimoniales' => c.copyWith(camasMatrimoniales: value),
        'banosCompletos' => c.copyWith(banosCompletos: value),
        'mediosBanos' => c.copyWith(mediosBanos: value),
        _ => c,
      },
    );
  }

  void toggleCabanaAmenidad(String amenidad) {
    final current = List<String>.from(state.cabana.amenidades);
    if (current.contains(amenidad)) {
      current.remove(amenidad);
    } else {
      current.add(amenidad);
    }
    state = state.copyWith(cabana: state.cabana.copyWith(amenidades: current));
  }

  /// Step 3: Specs de Alberca
  void setAlbercaSpecs(AlbercaSpecs specs) {
    state = state.copyWith(alberca: specs);
  }

  void updateAlbercaCounter(String field, int value) {
    final a = state.alberca;
    state = state.copyWith(
      alberca: switch (field) {
        'capacidad' => a.copyWith(capacidad: value),
        'banos' => a.copyWith(banos: value),
        'temperaturaMin' => a.copyWith(temperaturaMin: value),
        'temperaturaMax' => a.copyWith(temperaturaMax: value),
        _ => a,
      },
    );
  }

  void toggleAlbercaAmenidad(String amenidad) {
    final current = List<String>.from(state.alberca.amenidades);
    if (current.contains(amenidad)) {
      current.remove(amenidad);
    } else {
      current.add(amenidad);
    }
    state = state.copyWith(alberca: state.alberca.copyWith(amenidades: current));
  }

  /// Step 3: Specs de Camping
  void setCampingSpecs(CampingSpecs specs) {
    state = state.copyWith(camping: specs);
  }

  void updateCampingCounter(String field, int value) {
    final c = state.camping;
    state = state.copyWith(
      camping: switch (field) {
        'capacidadPersonas' => c.copyWith(capacidadPersonas: value),
        'metrosCuadrados' => c.copyWith(metrosCuadrados: value),
        'casasCampanaAprox' => c.copyWith(casasCampanaAprox: value),
        _ => c,
      },
    );
  }

  void toggleCampingAmenidad(String amenidad) {
    final current = List<String>.from(state.camping.amenidades);
    if (current.contains(amenidad)) {
      current.remove(amenidad);
    } else {
      current.add(amenidad);
    }
    state = state.copyWith(camping: state.camping.copyWith(amenidades: current));
  }

  /// Navegación
  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
}

/// Provider principal del registro de propiedad
final propertyRegistrationProvider =
    StateNotifierProvider<PropertyRegistrationNotifier, PropertyRegistrationState>((ref) {
  return PropertyRegistrationNotifier();
});
