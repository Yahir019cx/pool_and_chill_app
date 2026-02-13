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
  /// ID del estado en el catálogo (GET /catalogs/states). Requerido para POST /properties.
  final int? stateId;
  /// ID de la ciudad en el catálogo (GET /catalogs/cities/:stateId). Requerido para POST /properties.
  final int? cityId;

  const AddressData({
    this.calle = '',
    this.numero = '',
    this.colonia = '',
    this.cp = '',
    this.ciudad = '',
    this.estado = '',
    this.lat,
    this.lng,
    this.stateId,
    this.cityId,
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
    int? stateId,
    int? cityId,
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
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
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

/// Step 4: Información básica del espacio
@immutable
class BasicInfo {
  final String nombre;
  final String descripcion;
  final String checkIn;
  final String checkOut;
  final double precioLunesJueves;
  final double precioViernesDomingo;

  const BasicInfo({
    this.nombre = '',
    this.descripcion = '',
    this.checkIn = '12:00 PM',
    this.checkOut = '10:00 PM',
    this.precioLunesJueves = 0,
    this.precioViernesDomingo = 0,
  });

  bool get isValid =>
      nombre.trim().isNotEmpty &&
      descripcion.trim().isNotEmpty &&
      precioLunesJueves > 0 &&
      precioViernesDomingo > 0;

  BasicInfo copyWith({
    String? nombre,
    String? descripcion,
    String? checkIn,
    String? checkOut,
    double? precioLunesJueves,
    double? precioViernesDomingo,
  }) {
    return BasicInfo(
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      precioLunesJueves: precioLunesJueves ?? this.precioLunesJueves,
      precioViernesDomingo: precioViernesDomingo ?? this.precioViernesDomingo,
    );
  }
}

/// Step 6: Fotos del espacio
@immutable
class PropertyPhotos {
  final List<String> photoPaths;

  const PropertyPhotos({this.photoPaths = const []});

  bool get isValid => photoPaths.isNotEmpty;

  PropertyPhotos copyWith({List<String>? photoPaths}) {
    return PropertyPhotos(photoPaths: photoPaths ?? this.photoPaths);
  }
}

/// Step 7: Verificación de identidad (INE)
@immutable
class IdentityVerification {
  final String? ineFrontPath;
  final String? ineBackPath;
  final String? selfiePath;

  const IdentityVerification({
    this.ineFrontPath,
    this.ineBackPath,
    this.selfiePath,
  });

  bool get isComplete =>
      ineFrontPath != null && ineBackPath != null && selfiePath != null;

  IdentityVerification copyWith({
    String? ineFrontPath,
    String? ineBackPath,
    String? selfiePath,
  }) {
    return IdentityVerification(
      ineFrontPath: ineFrontPath ?? this.ineFrontPath,
      ineBackPath: ineBackPath ?? this.ineBackPath,
      selfiePath: selfiePath ?? this.selfiePath,
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
  final BasicInfo basicInfo;
  final List<String> reglas;
  final PropertyPhotos photos;
  final IdentityVerification identity;
  final int currentStep;

  const PropertyRegistrationState({
    this.tiposEspacioSeleccionados = const {},
    this.addressData,
    this.cabana = const CabanaSpecs(),
    this.alberca = const AlbercaSpecs(),
    this.camping = const CampingSpecs(),
    this.basicInfo = const BasicInfo(),
    this.reglas = const [],
    this.photos = const PropertyPhotos(),
    this.identity = const IdentityVerification(),
    this.currentStep = 1,
  });

  PropertyRegistrationState copyWith({
    Set<String>? tiposEspacioSeleccionados,
    AddressData? addressData,
    CabanaSpecs? cabana,
    AlbercaSpecs? alberca,
    CampingSpecs? camping,
    BasicInfo? basicInfo,
    List<String>? reglas,
    PropertyPhotos? photos,
    IdentityVerification? identity,
    int? currentStep,
  }) {
    return PropertyRegistrationState(
      tiposEspacioSeleccionados: tiposEspacioSeleccionados ?? this.tiposEspacioSeleccionados,
      addressData: addressData ?? this.addressData,
      cabana: cabana ?? this.cabana,
      alberca: alberca ?? this.alberca,
      camping: camping ?? this.camping,
      basicInfo: basicInfo ?? this.basicInfo,
      reglas: reglas ?? this.reglas,
      photos: photos ?? this.photos,
      identity: identity ?? this.identity,
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

  /// Valida si el registro está completo para enviar
  bool get isReadyToSubmit =>
      tiposEspacioSeleccionados.isNotEmpty &&
      addressData != null &&
      basicInfo.isValid &&
      photos.isValid &&
      identity.isComplete;
}
