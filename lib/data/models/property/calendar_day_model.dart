/// Modelo de un día del calendario de disponibilidad.
class CalendarDayModel {
  final String date; // "2026-02-16"
  final String availabilityStatus; // "available" | "booked" | "ownerBlocked"
  final String? blockReason;
  final double? price;
  final String? priceSource;
  final String? specialRateReason;
  final String? idSpecialRate;
  final String? dayName;
  final int? dayOfWeek;

  CalendarDayModel({
    required this.date,
    required this.availabilityStatus,
    this.blockReason,
    this.price,
    this.priceSource,
    this.specialRateReason,
    this.idSpecialRate,
    this.dayName,
    this.dayOfWeek,
  });

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) =>
      CalendarDayModel(
        date: json['date'] as String,
        availabilityStatus: json['availabilityStatus'] as String,
        blockReason: json['blockReason'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        priceSource: json['priceSource'] as String?,
        specialRateReason: json['specialRateReason'] as String?,
        idSpecialRate: json['idSpecialRate'] as String?,
        dayName: json['dayName'] as String?,
        dayOfWeek: json['dayOfWeek'] as int?,
      );

  bool get isAvailable => availabilityStatus == 'available';
  bool get isBooked => availabilityStatus == 'booked';
  bool get isOwnerBlocked => availabilityStatus == 'ownerBlocked';
  bool get isSpecialRate => priceSource == 'specialRate';

  DateTime get dateTime => DateTime.parse(date);

  static const _sentinel = Object();

  CalendarDayModel copyWith({
    String? availabilityStatus,
    Object? blockReason = _sentinel,
    Object? price = _sentinel,
    Object? priceSource = _sentinel,
    Object? idSpecialRate = _sentinel,
    Object? specialRateReason = _sentinel,
  }) {
    return CalendarDayModel(
      date: date,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      blockReason: blockReason == _sentinel ? this.blockReason : blockReason as String?,
      price: price == _sentinel ? this.price : price as double?,
      priceSource: priceSource == _sentinel ? this.priceSource : priceSource as String?,
      specialRateReason: specialRateReason == _sentinel ? this.specialRateReason : specialRateReason as String?,
      idSpecialRate: idSpecialRate == _sentinel ? this.idSpecialRate : idSpecialRate as String?,
      dayName: dayName,
      dayOfWeek: dayOfWeek,
    );
  }
}

/// Respuesta de POST /booking/calendar.
class CalendarAvailabilityResponse {
  final bool success;
  final CalendarAvailabilityData data;

  CalendarAvailabilityResponse({required this.success, required this.data});

  factory CalendarAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      CalendarAvailabilityResponse(
        success: json['success'] as bool,
        data: CalendarAvailabilityData.fromJson(
            json['data'] as Map<String, dynamic>),
      );
}

class CalendarAvailabilityData {
  final String propertyId;
  final List<CalendarDayModel> calendar;

  CalendarAvailabilityData({required this.propertyId, required this.calendar});

  factory CalendarAvailabilityData.fromJson(Map<String, dynamic> json) =>
      CalendarAvailabilityData(
        propertyId: json['propertyId'] as String,
        calendar: (json['calendar'] as List)
            .map((e) => CalendarDayModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
