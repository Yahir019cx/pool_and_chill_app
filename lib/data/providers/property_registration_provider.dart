import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/models/catalog_model.dart';
import 'package:pool_and_chill_app/data/services/property_service.dart';
import 'package:pool_and_chill_app/data/services/catalog_service.dart';
import 'package:pool_and_chill_app/data/services/stripe_service.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

/// Provider para el ApiClient (se sobreescribe en main.dart)
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider debe ser sobreescrito');
});

/// Provider para el servicio de propiedades
final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PropertyService(apiClient);
});

/// Provider para el servicio de catálogos (estados/ciudades)
final catalogServiceProvider = Provider<CatalogService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CatalogService(apiClient);
});

/// Provider para el servicio de Stripe Connect
final stripeServiceProvider = Provider<StripeService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return StripeService(apiClient);
});

/// Provider para el servicio de reservas
final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return BookingService(apiClient);
});

/// Catálogo de estados (GET /catalogs/states)
final statesCatalogProvider = FutureProvider<List<StateCatalogItem>>((ref) async {
  final service = ref.read(catalogServiceProvider);
  return service.getStates();
});

/// Ciudades por estado (GET /catalogs/cities/:stateId)
final citiesCatalogProvider = FutureProvider.family<List<CityCatalogItem>, int>((ref, stateId) async {
  final service = ref.read(catalogServiceProvider);
  return service.getCities(stateId);
});

/// Provider para las amenidades del catálogo
final amenitiesProvider = FutureProvider.family<List<AmenityModel>, String>((ref, categories) async {
  final service = ref.read(propertyServiceProvider);
  return service.getAmenities(categories);
});

/// Provider para el detalle de una propiedad por ID (POST /properties/by-id).
final propertyDetailProvider =
    FutureProvider.family<PropertyDetailResponse, String>((ref, propertyId) async {
  final service = ref.read(propertyServiceProvider);
  return service.getPropertyById(propertyId);
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

  /// Step 4: Información básica
  void setBasicInfo(BasicInfo info) {
    state = state.copyWith(basicInfo: info);
  }

  void updateBasicInfoField(String field, dynamic value) {
    final b = state.basicInfo;
    state = state.copyWith(
      basicInfo: switch (field) {
        'nombre' => b.copyWith(nombre: value as String),
        'descripcion' => b.copyWith(descripcion: value as String),
        'checkIn' => b.copyWith(checkIn: value as String),
        'checkOut' => b.copyWith(checkOut: value as String),
        'precioLunesJueves' => b.copyWith(precioLunesJueves: value as double),
        'precioViernesDomingo' => b.copyWith(precioViernesDomingo: value as double),
        'minNights' => value == null
            ? b.copyWith(clearMinNights: true)
            : b.copyWith(minNights: value as int),
        'maxNights' => value == null
            ? b.copyWith(clearMaxNights: true)
            : b.copyWith(maxNights: value as int),
        _ => b,
      },
    );
  }

  /// Step 5: Reglas
  void setReglas(List<String> reglas) {
    state = state.copyWith(reglas: reglas);
  }

  void addRegla(String regla) {
    if (regla.trim().isEmpty) return;
    state = state.copyWith(reglas: [...state.reglas, regla.trim()]);
  }

  void updateRegla(int index, String regla) {
    if (index < 0 || index >= state.reglas.length) return;
    final updated = List<String>.from(state.reglas);
    updated[index] = regla.trim();
    state = state.copyWith(reglas: updated);
  }

  void removeRegla(int index) {
    if (index < 0 || index >= state.reglas.length) return;
    final updated = List<String>.from(state.reglas)..removeAt(index);
    state = state.copyWith(reglas: updated);
  }

  /// Step 6: Fotos
  void addPhoto(String path) {
    final current = List<String>.from(state.photos.photoPaths);
    current.add(path);
    state = state.copyWith(photos: state.photos.copyWith(photoPaths: current));
  }

  void removePhoto(int index) {
    if (index < 0 || index >= state.photos.photoPaths.length) return;
    final current = List<String>.from(state.photos.photoPaths)..removeAt(index);
    state = state.copyWith(photos: state.photos.copyWith(photoPaths: current));
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final current = List<String>.from(state.photos.photoPaths);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    state = state.copyWith(photos: state.photos.copyWith(photoPaths: current));
  }

  /// Step 7: Verificación de identidad
  void setIneFront(String path) {
    state = state.copyWith(
      identity: state.identity.copyWith(ineFrontPath: path),
    );
  }

  void setIneBack(String path) {
    state = state.copyWith(
      identity: state.identity.copyWith(ineBackPath: path),
    );
  }

  void setSelfie(String path) {
    state = state.copyWith(
      identity: state.identity.copyWith(selfiePath: path),
    );
  }

  void clearIdentityPhoto(String type) {
    state = state.copyWith(
      identity: switch (type) {
        'front' => IdentityVerification(
            ineBackPath: state.identity.ineBackPath,
            selfiePath: state.identity.selfiePath,
          ),
        'back' => IdentityVerification(
            ineFrontPath: state.identity.ineFrontPath,
            selfiePath: state.identity.selfiePath,
          ),
        'selfie' => IdentityVerification(
            ineFrontPath: state.identity.ineFrontPath,
            ineBackPath: state.identity.ineBackPath,
          ),
        _ => state.identity,
      },
    );
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
