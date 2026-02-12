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

  /// Mayor maxCapacity entre pools, cabins y camping.
  int? get maxCapacityOverall {
    int? max;
    for (final p in pools) {
      if (p.maxCapacity != null) {
        final v = p.maxCapacity!.toInt();
        max = max == null ? v : (v > max ? v : max);
      }
    }
    for (final c in cabins) {
      if (c.maxCapacity != null) {
        final v = c.maxCapacity!.toInt();
        max = max == null ? v : (v > max ? v : max);
      }
    }
    for (final ca in campingAreas) {
      if (ca.maxCapacity != null) {
        final v = ca.maxCapacity!.toInt();
        max = max == null ? v : (v > max ? v : max);
      }
    }
    return max;
  }

  /// Total baños (suma de cabins).
  int? get totalBathrooms {
    int? sum;
    for (final c in cabins) {
      if (c.bathrooms != null) {
        sum = (sum ?? 0) + c.bathrooms!.toInt();
      }
    }
    return sum;
  }

  /// Total habitaciones (suma de cabins).
  int? get totalBedrooms {
    int? sum;
    for (final c in cabins) {
      if (c.bedrooms != null) {
        sum = (sum ?? 0) + c.bedrooms!.toInt();
      }
    }
    return sum;
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

  bool get hasCoordinates =>
      latitude != null && longitude != null;
}

// ─── Pools, Cabins, Camping ───────────────────────────────────────

class PoolDetail {
  final String idPool;
  final String idProperty;
  final String? poolName;
  final String? description;
  final double? maxCapacity;
  final double? depth;
  final double? length;
  final double? width;
  final double? pricePerPerson;
  final String? openingTime;
  final String? closingTime;
  final List<AmenityItem> amenities;

  PoolDetail({
    required this.idPool,
    required this.idProperty,
    this.poolName,
    this.description,
    this.maxCapacity,
    this.depth,
    this.length,
    this.width,
    this.pricePerPerson,
    this.openingTime,
    this.closingTime,
    this.amenities = const [],
  });

  factory PoolDetail.fromJson(Map<String, dynamic> json) {
    return PoolDetail(
      idPool: json['idPool'] ?? '',
      idProperty: json['idProperty'] ?? '',
      poolName: json['poolName'],
      description: json['description'],
      maxCapacity: (json['maxCapacity'] as num?)?.toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      pricePerPerson: (json['pricePerPerson'] as num?)?.toDouble(),
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CabinDetail {
  final String idCabin;
  final String idProperty;
  final String? cabinName;
  final String? description;
  final double? maxCapacity;
  final int? bedrooms;
  final int? bathrooms;
  final double? pricePerNight;
  final List<AmenityItem> amenities;

  CabinDetail({
    required this.idCabin,
    required this.idProperty,
    this.cabinName,
    this.description,
    this.maxCapacity,
    this.bedrooms,
    this.bathrooms,
    this.pricePerNight,
    this.amenities = const [],
  });

  factory CabinDetail.fromJson(Map<String, dynamic> json) {
    return CabinDetail(
      idCabin: json['idCabin'] ?? '',
      idProperty: json['idProperty'] ?? '',
      cabinName: json['cabinName'],
      description: json['description'],
      maxCapacity: (json['maxCapacity'] as num?)?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CampingAreaDetail {
  final String idCampingArea;
  final String idProperty;
  final String? areaName;
  final String? description;
  final double? maxCapacity;
  final double? pricePerPerson;
  final List<AmenityItem> amenities;

  CampingAreaDetail({
    required this.idCampingArea,
    required this.idProperty,
    this.areaName,
    this.description,
    this.maxCapacity,
    this.pricePerPerson,
    this.amenities = const [],
  });

  factory CampingAreaDetail.fromJson(Map<String, dynamic> json) {
    return CampingAreaDetail(
      idCampingArea: json['idCampingArea'] ?? '',
      idProperty: json['idProperty'] ?? '',
      areaName: json['areaName'],
      description: json['description'],
      maxCapacity: (json['maxCapacity'] as num?)?.toDouble(),
      pricePerPerson: (json['pricePerPerson'] as num?)?.toDouble(),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => AmenityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
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
