// Modelos para las peticiones y respuestas de actualización de propiedades.

// ─── Sub-modelos de request ──────────────────────────────────────

class AmenityItemRequest {
  final int amenityId;
  final int? quantity;

  const AmenityItemRequest({required this.amenityId, this.quantity});

  Map<String, dynamic> toJson() => {
        'amenityId': amenityId,
        if (quantity != null) 'quantity': quantity,
      };
}

class PoolPricingRequest {
  final String checkInTime;
  final String checkOutTime;
  final int maxHours;
  final int? minHours;
  final double priceWeekday;
  final double priceWeekend;

  const PoolPricingRequest({
    required this.checkInTime,
    required this.checkOutTime,
    required this.maxHours,
    this.minHours,
    required this.priceWeekday,
    required this.priceWeekend,
  });

  Map<String, dynamic> toJson() => {
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'maxHours': maxHours,
        if (minHours != null) 'minHours': minHours,
        'priceWeekday': priceWeekday,
        'priceWeekend': priceWeekend,
      };
}

class CabinPricingRequest {
  final String checkInTime;
  final String checkOutTime;
  final int? minNights;
  final int? maxNights;
  final double priceWeekday;
  final double priceWeekend;

  const CabinPricingRequest({
    required this.checkInTime,
    required this.checkOutTime,
    this.minNights,
    this.maxNights,
    required this.priceWeekday,
    required this.priceWeekend,
  });

  Map<String, dynamic> toJson() => {
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        if (minNights != null) 'minNights': minNights,
        if (maxNights != null) 'maxNights': maxNights,
        'priceWeekday': priceWeekday,
        'priceWeekend': priceWeekend,
      };
}

class CampingPricingRequest {
  final String checkInTime;
  final String checkOutTime;
  final int? minNights;
  final int? maxNights;
  final double priceWeekday;
  final double priceWeekend;

  const CampingPricingRequest({
    required this.checkInTime,
    required this.checkOutTime,
    this.minNights,
    this.maxNights,
    required this.priceWeekday,
    required this.priceWeekend,
  });

  Map<String, dynamic> toJson() => {
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        if (minNights != null) 'minNights': minNights,
        if (maxNights != null) 'maxNights': maxNights,
        'priceWeekday': priceWeekday,
        'priceWeekend': priceWeekend,
      };
}

class PropertyRuleRequest {
  final String text;
  final int order;

  const PropertyRuleRequest({required this.text, required this.order});

  Map<String, dynamic> toJson() => {'text': text, 'order': order};
}

// ─── Respuestas ──────────────────────────────────────────────────

class UpdateResponse {
  final bool success;
  final String message;

  const UpdateResponse({required this.success, required this.message});

  factory UpdateResponse.fromJson(Map<String, dynamic> json) => UpdateResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
      );
}

class AddImageResponse {
  final bool success;
  final String idPropertyImage;

  const AddImageResponse({
    required this.success,
    required this.idPropertyImage,
  });

  factory AddImageResponse.fromJson(Map<String, dynamic> json) =>
      AddImageResponse(
        success: json['success'] == true,
        idPropertyImage: json['idPropertyImage']?.toString() ?? '',
      );
}
