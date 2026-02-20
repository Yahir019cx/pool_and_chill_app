class CreateSpecialRateRequest {
  final String idProperty;
  final String propertyType; // 'pool' | 'cabin' | 'camping'
  final String startDate;    // YYYY-MM-DD
  final String endDate;      // YYYY-MM-DD
  final double specialPrice;
  final String? reason;
  final String? description;

  const CreateSpecialRateRequest({
    required this.idProperty,
    required this.propertyType,
    required this.startDate,
    required this.endDate,
    required this.specialPrice,
    this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'idProperty': idProperty,
        'propertyType': propertyType,
        'startDate': startDate,
        'endDate': endDate,
        'specialPrice': specialPrice,
        if (reason != null && reason!.isNotEmpty) 'reason': reason,
        if (description != null && description!.isNotEmpty)
          'description': description,
      };
}
