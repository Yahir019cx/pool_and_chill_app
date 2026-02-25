class CreateBookingRequest {
  final String propertyId;
  final String? bookingDate;
  final String? checkInDate;
  final String? checkOutDate;
  final String? guestNotes;
  final bool requiresInvoice;

  const CreateBookingRequest({
    required this.propertyId,
    this.bookingDate,
    this.checkInDate,
    this.checkOutDate,
    this.guestNotes,
    this.requiresInvoice = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'propertyId': propertyId,
      'requiresInvoice': requiresInvoice,
    };
    if (bookingDate != null) map['bookingDate'] = bookingDate;
    if (checkInDate != null) map['checkInDate'] = checkInDate;
    if (checkOutDate != null) map['checkOutDate'] = checkOutDate;
    if (guestNotes != null && guestNotes!.isNotEmpty) {
      map['guestNotes'] = guestNotes;
    }
    return map;
  }
}

class CreateBookingResponse {
  final bool success;
  final CreateBookingData data;

  const CreateBookingResponse({required this.success, required this.data});

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      success: json['success'] as bool? ?? false,
      data: CreateBookingData.fromJson(
          json['data'] as Map<String, dynamic>),
    );
  }
}

class CreateBookingData {
  final BookingInfo booking;
  final BookingPricing pricing;
  final BookingPayment payment;

  const CreateBookingData({
    required this.booking,
    required this.pricing,
    required this.payment,
  });

  factory CreateBookingData.fromJson(Map<String, dynamic> json) {
    return CreateBookingData(
      booking: BookingInfo.fromJson(json['booking'] as Map<String, dynamic>),
      pricing:
          BookingPricing.fromJson(json['pricing'] as Map<String, dynamic>),
      payment:
          BookingPayment.fromJson(json['payment'] as Map<String, dynamic>),
    );
  }
}

class BookingInfo {
  final String bookingId;
  final String bookingCode;

  const BookingInfo({required this.bookingId, required this.bookingCode});

  factory BookingInfo.fromJson(Map<String, dynamic> json) {
    return BookingInfo(
      bookingId: json['bookingId'] as String,
      bookingCode: json['bookingCode'] as String,
    );
  }
}

class BookingPricing {
  final double basePrice;
  final double guestServiceFee;
  final double totalIVA;
  final double totalGuestPayment;
  final List<PriceBreakdownItem> breakdown;

  const BookingPricing({
    required this.basePrice,
    required this.guestServiceFee,
    required this.totalIVA,
    required this.totalGuestPayment,
    required this.breakdown,
  });

  factory BookingPricing.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] as List<dynamic>? ?? [];
    return BookingPricing(
      basePrice: (json['basePrice'] as num).toDouble(),
      guestServiceFee: (json['guestServiceFee'] as num).toDouble(),
      totalIVA: (json['totalIVA'] as num).toDouble(),
      totalGuestPayment: (json['totalGuestPayment'] as num).toDouble(),
      breakdown: rawBreakdown
          .map((e) => PriceBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PriceBreakdownItem {
  final String date;
  final double price;
  final String source;

  const PriceBreakdownItem({
    required this.date,
    required this.price,
    required this.source,
  });

  factory PriceBreakdownItem.fromJson(Map<String, dynamic> json) {
    return PriceBreakdownItem(
      date: json['date'] as String,
      price: (json['price'] as num).toDouble(),
      source: json['source'] as String? ?? '',
    );
  }
}

class BookingPayment {
  final String clientSecret;
  final String paymentIntentId;

  const BookingPayment({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory BookingPayment.fromJson(Map<String, dynamic> json) {
    return BookingPayment(
      clientSecret: json['clientSecret'] as String,
      paymentIntentId: json['paymentIntentId'] as String,
    );
  }
}
