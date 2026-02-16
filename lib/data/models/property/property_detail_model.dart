/// Respuesta de POST /properties/by-id (solo el objeto `data`).
class PropertyDetailResponse {
  final PropertyDetailProperty property;
  final List<PoolDetail> pools;
  final List<CabinDetail> cabins;
  final List<CampingAreaDetail> campingAreas;
  final List<PropertyRule> rules;
  final List<PropertyImageDetail> images;

  PropertyDetailResponse({
    required this.property,
    this.pools = const [],
    this.cabins = const [],
    this.campingAreas = const [],
    this.rules = const [],
    this.images = const [],
  });

  factory PropertyDetailResponse.fromJson(Map<String, dynamic> json) {
    return PropertyDetailResponse(
      property: PropertyDetailProperty.fromJson(
        json['property'] as Map<String, dynamic>? ?? {},
      ),
      pools: (json['pools'] as List<dynamic>?)
              ?.map((e) => PoolDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cabins: (json['cabins'] as List<dynamic>?)
              ?.map((e) => CabinDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      campingAreas: (json['campingAreas'] as List<dynamic>?)
              ?.map((e) =>
                  CampingAreaDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => PropertyRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) =>
                  PropertyImageDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Imágenes ordenadas por displayOrder; la primaria primero.
  List<PropertyImageDetail> get sortedImages {
    final list = List<PropertyImageDetail>.from(images);
    list.sort((a, b) {
      if (a.isPrimary) return -1;
      if (b.isPrimary) return 1;
      return a.displayOrder.compareTo(b.displayOrder);
    });
    return list;
  }

  /// Amenidades únicas (por amenityCode o nombre) de pools, cabins y camping.
  List<AmenityItem> get allAmenities {
    final seen = <String>{};
    final result = <AmenityItem>[];
    String key(AmenityItem a) => a.amenityCode ?? a.amenityName ?? '';
    for (final p in pools) {
      for (final a in p.amenities) {
        if (seen.add(key(a))) result.add(a);
      }
    }
    for (final c in cabins) {
      for (final a in c.amenities) {
        if (seen.add(key(a))) result.add(a);
      }
    }
    for (final ca in campingAreas) {
      for (final a in ca.amenities) {
        if (seen.add(key(a))) result.add(a);
      }
    }
    return result;
  }

  /// Rango de precios global (min weekday - max weekend) de todos los tipos.
  ({int min, int max})? get priceRange {
    final prices = <int>[];
    for (final p in pools) {
      if (p.priceWeekday != null) prices.add(p.priceWeekday!);
      if (p.priceWeekend != null) prices.add(p.priceWeekend!);
    }
    for (final c in cabins) {
      if (c.priceWeekday != null) prices.add(c.priceWeekday!);
      if (c.priceWeekend != null) prices.add(c.priceWeekend!);
    }
    for (final ca in campingAreas) {
      if (ca.priceWeekday != null) prices.add(ca.priceWeekday!);
      if (ca.priceWeekend != null) prices.add(ca.priceWeekend!);
    }
    if (prices.isEmpty) return null;
    prices.sort();
    return (min: prices.first, max: prices.last);
  }

  /// Mayor capacidad entre pools, cabins y camping.
  int? get maxCapacityOverall {
    int? max;
    for (final p in pools) {
      if (p.maxPersons != null) {
        final v = p.maxPersons!;
        max = max == null ? v : (v > max ? v : max);
      }
    }
    for (final c in cabins) {
      if (c.maxGuests != null) {
        final v = c.maxGuests!;
        max = max == null ? v : (v > max ? v : max);
      }
    }
    for (final ca in campingAreas) {
      if (ca.maxPersons != null) {
        final v = ca.maxPersons!;
        max = max == null ? v : (v > max ? v : max);
      }
    }
    return max;
  }
}

// ─── Property (objeto principal) ───────────────────────────────────

class PropertyDetailProperty {
  final String idProperty;
  final String? idOwner;
  final String propertyName;
  final String? description;
  final bool hasPool;
  final bool hasCabin;
  final bool hasCamping;
  final int currentStep;
  final PropertyStatusDetail? status;
  final String? createdAt;
  final String? updatedAt;
  final String? submittedAt;
  final String? approvedAt;
  final PropertyLocationDetail? location;

  PropertyDetailProperty({
    required this.idProperty,
    this.idOwner,
    required this.propertyName,
    this.description,
    this.hasPool = false,
    this.hasCabin = false,
    this.hasCamping = false,
    this.currentStep = 0,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.approvedAt,
    this.location,
  });

  factory PropertyDetailProperty.fromJson(Map<String, dynamic> json) {
    return PropertyDetailProperty(
      idProperty: json['idProperty'] ?? '',
      idOwner: json['idOwner'],
      propertyName: json['propertyName'] ?? '',
      description: json['description'],
      hasPool: json['hasPool'] == true,
      hasCabin: json['hasCabin'] == true,
      hasCamping: json['hasCamping'] == true,
      currentStep: json['currentStep'] ?? 0,
      status: json['status'] != null
          ? PropertyStatusDetail.fromJson(
              json['status'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      submittedAt: json['submittedAt'],
      approvedAt: json['approvedAt'],
      location: json['location'] != null
          ? PropertyLocationDetail.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PropertyStatusDetail {
  final int? idStatus;
  final String? statusName;
  final String? statusCode;

  PropertyStatusDetail({
    this.idStatus,
    this.statusName,
    this.statusCode,
  });

  factory PropertyStatusDetail.fromJson(Map<String, dynamic> json) {
    return PropertyStatusDetail(
      idStatus: json['idStatus'],
      statusName: json['statusName'],
      statusCode: json['statusCode'],
    );
  }
}

class PropertyLocationDetail {
  final String? street;
  final String? exteriorNumber;
  final String? interiorNumber;
  final String? neighborhood;
  final String? zipCode;
  final int? idState;
  final String? stateName;
  final int? idCity;
  final String? cityName;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;

  PropertyLocationDetail({
    this.street,
    this.exteriorNumber,
    this.interiorNumber,
    this.neighborhood,
    this.zipCode,
    this.idState,
    this.stateName,
    this.idCity,
    this.cityName,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  factory PropertyLocationDetail.fromJson(Map<String, dynamic> json) {
    return PropertyLocationDetail(
      street: json['street'],
      exteriorNumber: json['exteriorNumber'],
      interiorNumber: json['interiorNumber'],
      neighborhood: json['neighborhood'],
      zipCode: json['zipCode'],
      idState: json['idState'],
      stateName: json['stateName'],
      idCity: json['idCity'],
      cityName: json['cityName'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      formattedAddress: json['formattedAddress'],
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}

// ─── Pools, Cabins, Camping ───────────────────────────────────────

class PoolDetail {
  final String idPool;
  final String idProperty;
  final int? maxPersons;
  final int? temperatureMin;
  final int? temperatureMax;
  final String? checkInTime;
  final String? checkOutTime;
  final int? maxHours;
  final int? minHours;
  final int? priceWeekday;
  final int? priceWeekend;
  final int? securityDeposit;
  final List<AmenityItem> amenities;

  PoolDetail({
    required this.idPool,
    required this.idProperty,
    this.maxPersons,
    this.temperatureMin,
    this.temperatureMax,
    this.checkInTime,
    this.checkOutTime,
    this.maxHours,
    this.minHours,
    this.priceWeekday,
    this.priceWeekend,
    this.securityDeposit,
    this.amenities = const [],
  });

  factory PoolDetail.fromJson(Map<String, dynamic> json) {
    return PoolDetail(
      idPool: json['idPool'] ?? '',
      idProperty: json['idProperty'] ?? '',
      maxPersons: (json['maxPersons'] as num?)?.toInt(),
      temperatureMin: (json['temperatureMin'] as num?)?.toInt(),
      temperatureMax: (json['temperatureMax'] as num?)?.toInt(),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      maxHours: (json['maxHours'] as num?)?.toInt(),
      minHours: (json['minHours'] as num?)?.toInt(),
      priceWeekday: (json['priceWeekday'] as num?)?.toInt(),
      priceWeekend: (json['priceWeekend'] as num?)?.toInt(),
      securityDeposit: (json['securityDeposit'] as num?)?.toInt(),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedCheckIn => _formatTime(checkInTime);
  String get formattedCheckOut => _formatTime(checkOutTime);
}

class CabinDetail {
  final String idCabin;
  final String idProperty;
  final int? maxGuests;
  final int? bedrooms;
  final int? singleBeds;
  final int? doubleBeds;
  final int? fullBathrooms;
  final int? halfBathrooms;
  final String? checkInTime;
  final String? checkOutTime;
  final int? minNights;
  final int? maxNights;
  final int? priceWeekday;
  final int? priceWeekend;
  final int? securityDeposit;
  final List<AmenityItem> amenities;

  CabinDetail({
    required this.idCabin,
    required this.idProperty,
    this.maxGuests,
    this.bedrooms,
    this.singleBeds,
    this.doubleBeds,
    this.fullBathrooms,
    this.halfBathrooms,
    this.checkInTime,
    this.checkOutTime,
    this.minNights,
    this.maxNights,
    this.priceWeekday,
    this.priceWeekend,
    this.securityDeposit,
    this.amenities = const [],
  });

  factory CabinDetail.fromJson(Map<String, dynamic> json) {
    return CabinDetail(
      idCabin: json['idCabin'] ?? '',
      idProperty: json['idProperty'] ?? '',
      maxGuests: (json['maxGuests'] as num?)?.toInt(),
      bedrooms: (json['bedrooms'] as num?)?.toInt(),
      singleBeds: (json['singleBeds'] as num?)?.toInt(),
      doubleBeds: (json['doubleBeds'] as num?)?.toInt(),
      fullBathrooms: (json['fullBathrooms'] as num?)?.toInt(),
      halfBathrooms: (json['halfBathrooms'] as num?)?.toInt(),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      minNights: (json['minNights'] as num?)?.toInt(),
      maxNights: (json['maxNights'] as num?)?.toInt(),
      priceWeekday: (json['priceWeekday'] as num?)?.toInt(),
      priceWeekend: (json['priceWeekend'] as num?)?.toInt(),
      securityDeposit: (json['securityDeposit'] as num?)?.toInt(),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get totalBathrooms => (fullBathrooms ?? 0) + (halfBathrooms ?? 0);
  int get totalBeds => (singleBeds ?? 0) + (doubleBeds ?? 0);

  String get formattedCheckIn => _formatTime(checkInTime);
  String get formattedCheckOut => _formatTime(checkOutTime);
}

class CampingAreaDetail {
  final String idCampingArea;
  final String idProperty;
  final int? maxPersons;
  final int? areaSquareMeters;
  final int? approxTents;
  final String? checkInTime;
  final String? checkOutTime;
  final int? minNights;
  final int? maxNights;
  final int? priceWeekday;
  final int? priceWeekend;
  final int? securityDeposit;
  final List<AmenityItem> amenities;

  CampingAreaDetail({
    required this.idCampingArea,
    required this.idProperty,
    this.maxPersons,
    this.areaSquareMeters,
    this.approxTents,
    this.checkInTime,
    this.checkOutTime,
    this.minNights,
    this.maxNights,
    this.priceWeekday,
    this.priceWeekend,
    this.securityDeposit,
    this.amenities = const [],
  });

  factory CampingAreaDetail.fromJson(Map<String, dynamic> json) {
    return CampingAreaDetail(
      idCampingArea: json['idCampingArea'] ?? '',
      idProperty: json['idProperty'] ?? '',
      maxPersons: (json['maxPersons'] as num?)?.toInt(),
      areaSquareMeters: (json['areaSquareMeters'] as num?)?.toInt(),
      approxTents: (json['approxTents'] as num?)?.toInt(),
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      minNights: (json['minNights'] as num?)?.toInt(),
      maxNights: (json['maxNights'] as num?)?.toInt(),
      priceWeekday: (json['priceWeekday'] as num?)?.toInt(),
      priceWeekend: (json['priceWeekend'] as num?)?.toInt(),
      securityDeposit: (json['securityDeposit'] as num?)?.toInt(),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get formattedCheckIn => _formatTime(checkInTime);
  String get formattedCheckOut => _formatTime(checkOutTime);
}

class AmenityItem {
  final String? amenityName;
  final String? amenityCode;
  final String? icon;
  final num? quantity;

  AmenityItem({
    this.amenityName,
    this.amenityCode,
    this.icon,
    this.quantity,
  });

  factory AmenityItem.fromJson(Map<String, dynamic> json) {
    return AmenityItem(
      amenityName: json['amenityName'],
      amenityCode: json['amenityCode'],
      icon: json['icon'],
      quantity: json['quantity'],
    );
  }
}

class PropertyRule {
  final String idPropertyRule;
  final String ruleText;
  final int displayOrder;

  PropertyRule({
    required this.idPropertyRule,
    required this.ruleText,
    this.displayOrder = 0,
  });

  factory PropertyRule.fromJson(Map<String, dynamic> json) {
    return PropertyRule(
      idPropertyRule: json['idPropertyRule'] ?? '',
      ruleText: json['ruleText'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

class PropertyImageDetail {
  final String idPropertyImage;
  final String imageURL;
  final bool isPrimary;
  final int displayOrder;

  PropertyImageDetail({
    required this.idPropertyImage,
    required this.imageURL,
    this.isPrimary = false,
    this.displayOrder = 0,
  });

  factory PropertyImageDetail.fromJson(Map<String, dynamic> json) {
    return PropertyImageDetail(
      idPropertyImage: json['idPropertyImage'] ?? '',
      imageURL: json['imageURL'] ?? json['imageUrl'] ?? '',
      isPrimary: json['isPrimary'] == true,
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

/// Formatea una fecha ISO (e.g. "1970-01-01T14:00:00.000Z") a hora legible "2:00 PM".
String _formatTime(String? isoTime) {
  if (isoTime == null) return '--';
  try {
    final dt = DateTime.parse(isoTime);
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h12:$m $period';
  } catch (_) {
    return '--';
  }
}
