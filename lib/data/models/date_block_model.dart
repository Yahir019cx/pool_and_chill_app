class CreateDateBlockRequest {
  final String idProperty;
  final String propertyType; // 'pool' | 'cabin' | 'camping'
  final String startDate;    // YYYY-MM-DD
  final String endDate;      // YYYY-MM-DD
  final String reason;       // maintenance | personal_use | renovation | weather | other
  final String? notes;

  const CreateDateBlockRequest({
    required this.idProperty,
    required this.propertyType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'idProperty': idProperty,
        'propertyType': propertyType,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class DeleteDateBlockRequest {
  final String idProperty;
  final String propertyType; // 'pool' | 'cabin' | 'camping'
  final String startDate;    // YYYY-MM-DD
  final String endDate;      // YYYY-MM-DD

  const DeleteDateBlockRequest({
    required this.idProperty,
    required this.propertyType,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'idProperty': idProperty,
        'propertyType': propertyType,
        'startDate': startDate,
        'endDate': endDate,
      };
}
