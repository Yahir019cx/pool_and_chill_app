import 'package:flutter/foundation.dart';

@immutable
class AddressData {
  final String calle;
  final String numero;
  final String colonia;
  final String cp;
  final String ciudad;
  final String estado;
  final double? lat;
  final double? lng;

  const AddressData({
    this.calle = '',
    this.numero = '',
    this.colonia = '',
    this.cp = '',
    this.ciudad = '',
    this.estado = '',
    this.lat,
    this.lng,
  });

  String toGeocodingString() => '$calle $numero, $colonia, $cp, $ciudad, $estado';

  AddressData copyWith({
    String? calle,
    String? numero,
    String? colonia,
    String? cp,
    String? ciudad,
    String? estado,
    double? lat,
    double? lng,
  }) {
    return AddressData(
      calle: calle ?? this.calle,
      numero: numero ?? this.numero,
      colonia: colonia ?? this.colonia,
      cp: cp ?? this.cp,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

@immutable
class CabanaSpecs {
  final int huespedes;
  final int recamaras;
  final int camasIndividuales;
  final int camasMatrimoniales;
  final int banosCompletos;
  final int mediosBanos;
  final List<String> amenidades;

  const CabanaSpecs({
    this.huespedes = 0,
    this.recamaras = 0,
    this.camasIndividuales = 0,
    this.camasMatrimoniales = 0,
    this.banosCompletos = 0,
    this.mediosBanos = 0,
    this.amenidades = const [],
  });

  CabanaSpecs copyWith({
    int? huespedes,
    int? recamaras,
    int? camasIndividuales,
    int? camasMatrimoniales,
    int? banosCompletos,
    int? mediosBanos,
    List<String>? amenidades,
  }) {
    return CabanaSpecs(
      huespedes: huespedes ?? this.huespedes,
      recamaras: recamaras ?? this.recamaras,
      camasIndividuales: camasIndividuales ?? this.camasIndividuales,
      camasMatrimoniales: camasMatrimoniales ?? this.camasMatrimoniales,
      banosCompletos: banosCompletos ?? this.banosCompletos,
      mediosBanos: mediosBanos ?? this.mediosBanos,
      amenidades: amenidades ?? this.amenidades,
    );
  }
}

@immutable
class AlbercaSpecs {
  final int capacidad;
  final int banos;
  final int temperaturaMin;
  final int temperaturaMax;
  final List<String> amenidades;

  const AlbercaSpecs({
    this.capacidad = 0,
    this.banos = 0,
    this.temperaturaMin = 20,
    this.temperaturaMax = 25,
    this.amenidades = const [],
  });

  String get rangoTemperatura => '$temperaturaMin° - $temperaturaMax°';

  AlbercaSpecs copyWith({
    int? capacidad,
    int? banos,
    int? temperaturaMin,
    int? temperaturaMax,
    List<String>? amenidades,
  }) {
    return AlbercaSpecs(
      capacidad: capacidad ?? this.capacidad,
      banos: banos ?? this.banos,
      temperaturaMin: temperaturaMin ?? this.temperaturaMin,
      temperaturaMax: temperaturaMax ?? this.temperaturaMax,
      amenidades: amenidades ?? this.amenidades,
    );
  }
}

@immutable
class CampingSpecs {
  final int capacidadPersonas;
  final int metrosCuadrados;
  final int casasCampanaAprox;
  final List<String> amenidades;

  const CampingSpecs({
    this.capacidadPersonas = 0,
    this.metrosCuadrados = 0,
    this.casasCampanaAprox = 0,
    this.amenidades = const [],
  });

  CampingSpecs copyWith({
    int? capacidadPersonas,
    int? metrosCuadrados,
    int? casasCampanaAprox,
    List<String>? amenidades,
  }) {
    return CampingSpecs(
      capacidadPersonas: capacidadPersonas ?? this.capacidadPersonas,
      metrosCuadrados: metrosCuadrados ?? this.metrosCuadrados,
      casasCampanaAprox: casasCampanaAprox ?? this.casasCampanaAprox,
      amenidades: amenidades ?? this.amenidades,
    );
  }
}

@immutable
class PropertyRegistrationState {
  final Set<String> tiposEspacioSeleccionados;
  final AddressData? addressData;
  final CabanaSpecs cabana;
  final AlbercaSpecs alberca;
  final CampingSpecs camping;
  final int currentStep;

  const PropertyRegistrationState({
    this.tiposEspacioSeleccionados = const {},
    this.addressData,
    this.cabana = const CabanaSpecs(),
    this.alberca = const AlbercaSpecs(),
    this.camping = const CampingSpecs(),
    this.currentStep = 1,
  });

  PropertyRegistrationState copyWith({
    Set<String>? tiposEspacioSeleccionados,
    AddressData? addressData,
    CabanaSpecs? cabana,
    AlbercaSpecs? alberca,
    CampingSpecs? camping,
    int? currentStep,
  }) {
    return PropertyRegistrationState(
      tiposEspacioSeleccionados: tiposEspacioSeleccionados ?? this.tiposEspacioSeleccionados,
      addressData: addressData ?? this.addressData,
      cabana: cabana ?? this.cabana,
      alberca: alberca ?? this.alberca,
      camping: camping ?? this.camping,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Convierte los tipos seleccionados a categorías del API
  List<String> get categoriasApi {
    final map = {
      'Cabaña': 'cabin',
      'Alberca': 'pool',
      'Camping': 'camping',
    };
    return tiposEspacioSeleccionados.map((t) => map[t] ?? t.toLowerCase()).toList();
  }

  /// Query string para el API de amenidades
  String get categoriasQuery => categoriasApi.join(',');
}
