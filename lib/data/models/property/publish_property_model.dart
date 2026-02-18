import 'package:pool_and_chill_app/data/models/property/property_registration_model.dart';

/// DTOs para el body de POST /properties (camelCase, estructura exacta del backend).
/// Se construye desde PropertyRegistrationState + URLs de imágenes.

// --- services ---
class PublishServicesDto {
  final bool hasPool;
  final bool hasCabin;
  final bool hasCamping;

  const PublishServicesDto({
    required this.hasPool,
    required this.hasCabin,
    required this.hasCamping,
  });

  Map<String, dynamic> toJson() => {
        'hasPool': hasPool,
        'hasCabin': hasCabin,
        'hasCamping': hasCamping,
      };
}

// --- location ---
class PublishLocationDto {
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String? neighborhood;
  final String zipCode;
  final int stateId;
  final int cityId;
  final double latitude;
  final double longitude;
  final String? googlePlaceId;
  final String? formattedAddress;

  const PublishLocationDto({
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    this.neighborhood,
    required this.zipCode,
    required this.stateId,
    required this.cityId,
    required this.latitude,
    required this.longitude,
    this.googlePlaceId,
    this.formattedAddress,
  });

  Map<String, dynamic> toJson() => {
        'street': street,
        'exteriorNumber': exteriorNumber,
        'interiorNumber': interiorNumber,
        'neighborhood': neighborhood,
        'zipCode': zipCode,
        'stateId': stateId,
        'cityId': cityId,
        'latitude': latitude,
        'longitude': longitude,
        'googlePlaceId': googlePlaceId,
        'formattedAddress': formattedAddress,
      };
}

// --- basicInfo: pool / cabin / camping (mismo esquema de horarios y precios) ---
class PublishBasicServiceDto {
  final String checkInTime;
  final String checkOutTime;
  final int? maxHours;
  final int? minHours;
  final double priceWeekday;
  final double priceWeekend;

  const PublishBasicServiceDto({
    required this.checkInTime,
    required this.checkOutTime,
    this.maxHours,
    this.minHours,
    required this.priceWeekday,
    required this.priceWeekend,
  });

  Map<String, dynamic> toJson() => {
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        if (maxHours != null) 'maxHours': maxHours,
        if (minHours != null) 'minHours': minHours,
        'priceWeekday': priceWeekday,
        'priceWeekend': priceWeekend,
      };
}

// --- basicInfo ---
class PublishBasicInfoDto {
  final String propertyName;
  final String? description;
  final PublishBasicServiceDto? pool;
  final PublishBasicServiceDto? cabin;
  final PublishBasicServiceDto? camping;

  const PublishBasicInfoDto({
    required this.propertyName,
    this.description,
    this.pool,
    this.cabin,
    this.camping,
  });

  Map<String, dynamic> toJson() => {
        'propertyName': propertyName,
        if (description != null && description!.isNotEmpty) 'description': description,
        'pool': pool?.toJson(),
        'cabin': cabin?.toJson(),
        'camping': camping?.toJson(),
      };
}

// --- amenities items ---
class PublishAmenityItemDto {
  final int amenityId;
  final int? quantity;

  const PublishAmenityItemDto({required this.amenityId, this.quantity});

  Map<String, dynamic> toJson() => {
        'amenityId': amenityId,
        if (quantity != null) 'quantity': quantity,
      };
}

// --- amenities: pool ---
class PublishAmenitiesPoolDto {
  final int maxPersons;
  final double? temperatureMin;
  final double? temperatureMax;
  final List<PublishAmenityItemDto> items;

  const PublishAmenitiesPoolDto({
    required this.maxPersons,
    this.temperatureMin,
    this.temperatureMax,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'maxPersons': maxPersons,
        if (temperatureMin != null) 'temperatureMin': temperatureMin,
        if (temperatureMax != null) 'temperatureMax': temperatureMax,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// --- amenities: cabin ---
class PublishAmenitiesCabinDto {
  final int maxGuests;
  final int bedrooms;
  final int singleBeds;
  final int doubleBeds;
  final int fullBathrooms;
  final int? halfBathrooms;
  final List<PublishAmenityItemDto> items;

  const PublishAmenitiesCabinDto({
    required this.maxGuests,
    required this.bedrooms,
    required this.singleBeds,
    required this.doubleBeds,
    required this.fullBathrooms,
    this.halfBathrooms,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'maxGuests': maxGuests,
        'bedrooms': bedrooms,
        'singleBeds': singleBeds,
        'doubleBeds': doubleBeds,
        'fullBathrooms': fullBathrooms,
        if (halfBathrooms != null) 'halfBathrooms': halfBathrooms,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// --- amenities: camping ---
class PublishAmenitiesCampingDto {
  final int maxPersons;
  final double? areaSquareMeters;
  final int? approxTents;
  final List<PublishAmenityItemDto> items;

  const PublishAmenitiesCampingDto({
    required this.maxPersons,
    this.areaSquareMeters,
    this.approxTents,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'maxPersons': maxPersons,
        if (areaSquareMeters != null) 'areaSquareMeters': areaSquareMeters,
        if (approxTents != null) 'approxTents': approxTents,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// --- amenities (wrapper) ---
class PublishAmenitiesDto {
  final PublishAmenitiesPoolDto? pool;
  final PublishAmenitiesCabinDto? cabin;
  final PublishAmenitiesCampingDto? camping;

  const PublishAmenitiesDto({
    this.pool,
    this.cabin,
    this.camping,
  });

  Map<String, dynamic> toJson() => {
        'pool': pool?.toJson(),
        'cabin': cabin?.toJson(),
        'camping': camping?.toJson(),
      };
}

// --- rules ---
class PublishRuleDto {
  final String text;
  final int order;

  const PublishRuleDto({required this.text, required this.order});

  Map<String, dynamic> toJson() => {'text': text, 'order': order};
}

// --- images ---
class PublishImageDto {
  final String url;
  final bool isPrimary;
  final int order;

  const PublishImageDto({
    required this.url,
    required this.isPrimary,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'isPrimary': isPrimary,
        'order': order,
      };
}

// --- body completo ---
class PublishPropertyBody {
  final PublishServicesDto services;
  final PublishLocationDto location;
  final PublishBasicInfoDto basicInfo;
  final PublishAmenitiesDto amenities;
  final List<PublishRuleDto> rules;
  final List<PublishImageDto> images;

  const PublishPropertyBody({
    required this.services,
    required this.location,
    required this.basicInfo,
    required this.amenities,
    required this.rules,
    required this.images,
  });

  Map<String, dynamic> toJson() => {
        'services': services.toJson(),
        'location': location.toJson(),
        'basicInfo': basicInfo.toJson(),
        'amenities': amenities.toJson(),
        'rules': rules.map((e) => e.toJson()).toList(),
        'images': images.map((e) => e.toJson()).toList(),
      };
}

// --- Respuesta 201 ---
class PublishPropertyResponse {
  final bool success;
  final String message;
  final String? propertyId;

  const PublishPropertyResponse({
    required this.success,
    required this.message,
    this.propertyId,
  });

  factory PublishPropertyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PublishPropertyResponse(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      propertyId: data['propertyId']?.toString(),
    );
  }
}

// --- Helpers: convertir "12:00 PM" -> "12:00", "2:00 PM" -> "14:00" ---
String _timeToBackend(String uiTime) {
  final lower = uiTime.toLowerCase().trim();
  if (lower.endsWith('am')) {
    final part = lower.replaceAll('am', '').trim();
    final parts = part.split(':');
    final h = int.tryParse(parts.first.trim()) ?? 12;
    final m = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    if (h == 12) return '00:${m.toString().padLeft(2, '0')}';
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
  if (lower.endsWith('pm')) {
    final part = lower.replaceAll('pm', '').trim();
    final parts = part.split(':');
    int h = int.tryParse(parts.first.trim()) ?? 12;
    final m = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    if (h != 12) h += 12;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
  return uiTime;
}

/// Mapea nombre de amenidad a ID. Si no existe, se omite.
typedef AmenityNameToId = int? Function(String name);

/// Construye el body de POST /properties desde el estado del wizard y las URLs de imágenes.
/// [amenityNameToId]: opcional; si no se pasa, items de amenidades quedarán vacíos.
PublishPropertyBody buildPublishPropertyBody(
  PropertyRegistrationState state,
  List<String> imageUrls, {
  AmenityNameToId? amenityNameToId,
}) {
  final addr = state.addressData!;
  final hasPool = state.tiposEspacioSeleccionados.contains('Alberca');
  final hasCabin = state.tiposEspacioSeleccionados.contains('Cabaña');
  final hasCamping = state.tiposEspacioSeleccionados.contains('Camping');

  final services = PublishServicesDto(
    hasPool: hasPool,
    hasCabin: hasCabin,
    hasCamping: hasCamping,
  );

  final location = PublishLocationDto(
    street: addr.calle,
    exteriorNumber: addr.numero,
    interiorNumber: null,
    neighborhood: addr.colonia.isNotEmpty ? addr.colonia : null,
    zipCode: addr.cp,
    stateId: addr.stateId ?? 0,
    cityId: addr.cityId ?? 0,
    latitude: addr.lat ?? 0.0,
    longitude: addr.lng ?? 0.0,
    googlePlaceId: null,
    formattedAddress: addr.toGeocodingString(),
  );

  final basicService = PublishBasicServiceDto(
    checkInTime: _timeToBackend(state.basicInfo.checkIn),
    checkOutTime: _timeToBackend(state.basicInfo.checkOut),
    priceWeekday: state.basicInfo.precioLunesJueves,
    priceWeekend: state.basicInfo.precioViernesDomingo,
  );

  final basicInfo = PublishBasicInfoDto(
    propertyName: state.basicInfo.nombre,
    description: state.basicInfo.descripcion.isNotEmpty ? state.basicInfo.descripcion : null,
    pool: hasPool ? basicService : null,
    cabin: hasCabin ? basicService : null,
    camping: hasCamping ? basicService : null,
  );

  List<PublishAmenityItemDto> _items(List<String> names) {
    if (amenityNameToId == null) return [];
    final list = <PublishAmenityItemDto>[];
    for (final name in names) {
      final id = amenityNameToId(name);
      if (id != null) list.add(PublishAmenityItemDto(amenityId: id, quantity: 1));
    }
    return list;
  }

  final amenities = PublishAmenitiesDto(
    pool: hasPool
        ? PublishAmenitiesPoolDto(
            maxPersons: state.alberca.capacidad,
            temperatureMin: state.alberca.temperaturaMin.toDouble(),
            temperatureMax: state.alberca.temperaturaMax.toDouble(),
            items: _items(state.alberca.amenidades),
          )
        : null,
    cabin: hasCabin
        ? PublishAmenitiesCabinDto(
            maxGuests: state.cabana.huespedes,
            bedrooms: state.cabana.recamaras,
            singleBeds: state.cabana.camasIndividuales,
            doubleBeds: state.cabana.camasMatrimoniales,
            fullBathrooms: state.cabana.banosCompletos,
            halfBathrooms: state.cabana.mediosBanos > 0 ? state.cabana.mediosBanos : null,
            items: _items(state.cabana.amenidades),
          )
        : null,
    camping: hasCamping
        ? PublishAmenitiesCampingDto(
            maxPersons: state.camping.capacidadPersonas,
            areaSquareMeters: state.camping.metrosCuadrados > 0
                ? state.camping.metrosCuadrados.toDouble()
                : null,
            approxTents: state.camping.casasCampanaAprox > 0
                ? state.camping.casasCampanaAprox
                : null,
            items: _items(state.camping.amenidades),
          )
        : null,
  );

  final rules = state.reglas
      .asMap()
      .entries
      .map((e) => PublishRuleDto(text: e.value, order: e.key + 1))
      .toList();

  final images = imageUrls
      .asMap()
      .entries
      .map((e) => PublishImageDto(
            url: e.value,
            isPrimary: e.key == 0,
            order: e.key + 1,
          ))
      .toList();

  return PublishPropertyBody(
    services: services,
    location: location,
    basicInfo: basicInfo,
    amenities: amenities,
    rules: rules,
    images: images,
  );
}
