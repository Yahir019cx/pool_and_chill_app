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

// ─── Guest Bookings (POST /booking/guest/bookings) ─────────────────

class GuestBookingsResponse {
  final bool success;
  final GuestBookingsData data;

  const GuestBookingsResponse({required this.success, required this.data});

  factory GuestBookingsResponse.fromJson(Map<String, dynamic> json) {
    return GuestBookingsResponse(
      success: json['success'] as bool? ?? false,
      data: GuestBookingsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class GuestBookingsData {
  final BookingsSummary summary;
  final List<GuestBooking> bookings;

  const GuestBookingsData({required this.summary, required this.bookings});

  factory GuestBookingsData.fromJson(Map<String, dynamic> json) {
    final rawBookings = json['bookings'] as List<dynamic>? ?? [];
    return GuestBookingsData(
      summary: BookingsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      bookings: rawBookings
          .map((e) => GuestBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BookingsSummary {
  final int totalBookings;
  final int totalProximas;
  final int totalPasadas;
  final int totalCanceladas;
  final int totalNoShow;

  const BookingsSummary({
    required this.totalBookings,
    required this.totalProximas,
    required this.totalPasadas,
    required this.totalCanceladas,
    required this.totalNoShow,
  });

  factory BookingsSummary.fromJson(Map<String, dynamic> json) {
    return BookingsSummary(
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalProximas: json['totalProximas'] as int? ?? 0,
      totalPasadas: json['totalPasadas'] as int? ?? 0,
      totalCanceladas: json['totalCanceladas'] as int? ?? 0,
      totalNoShow: json['totalNoShow'] as int? ?? 0,
    );
  }
}

class GuestBooking {
  final String bookingId;
  final String bookingCode;
  final String bookingType;
  final String bookingDate;
  final String bookingStartTime;
  final String bookingEndTime;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfNights;
  final String qrCodeData;
  final String propertyId;
  final String propertyName;
  final String? propertyImageUrl;
  final GuestBookingRating propertyRating;
  final GuestBookingRating guestRating;
  final GuestBookingHost host;
  final double totalGuestPayment;
  final GuestBookingStatus status;

  const GuestBooking({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingType,
    required this.bookingDate,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.qrCodeData,
    required this.propertyId,
    required this.propertyName,
    this.propertyImageUrl,
    required this.propertyRating,
    required this.guestRating,
    required this.host,
    required this.totalGuestPayment,
    required this.status,
  });

  factory GuestBooking.fromJson(Map<String, dynamic> json) {
    return GuestBooking(
      bookingId: json['bookingId'] as String? ?? '',
      bookingCode: json['bookingCode'] as String? ?? '',
      bookingType: json['bookingType'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingStartTime: json['bookingStartTime'] as String? ?? '',
      bookingEndTime: json['bookingEndTime'] as String? ?? '',
      checkInDate: json['checkInDate'] as String? ?? '',
      checkOutDate: json['checkOutDate'] as String? ?? '',
      numberOfNights: json['numberOfNights'] as int? ?? 0,
      qrCodeData: json['qrCodeData'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      propertyName: json['propertyName'] as String? ?? '',
      propertyImageUrl: json['propertyImageUrl'] as String?,
      propertyRating: GuestBookingRating.fromJson(
          json['propertyRating'] as Map<String, dynamic>? ?? {}),
      guestRating: GuestBookingRating.fromJson(
          json['guestRating'] as Map<String, dynamic>? ?? {}),
      host: GuestBookingHost.fromJson(
          json['host'] as Map<String, dynamic>? ?? {}),
      totalGuestPayment: (json['totalGuestPayment'] as num?)?.toDouble() ?? 0,
      status: GuestBookingStatus.fromJson(
          json['status'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class GuestBookingRating {
  final double average;
  final int totalReviews;

  const GuestBookingRating({required this.average, required this.totalReviews});

  factory GuestBookingRating.fromJson(Map<String, dynamic> json) {
    return GuestBookingRating(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }
}

class GuestBookingHost {
  final String hostId;
  final String displayName;
  final String? profileImageUrl;
  final bool isIdentityVerified;

  const GuestBookingHost({
    required this.hostId,
    required this.displayName,
    this.profileImageUrl,
    required this.isIdentityVerified,
  });

  factory GuestBookingHost.fromJson(Map<String, dynamic> json) {
    return GuestBookingHost(
      hostId: json['hostId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      isIdentityVerified: json['isIdentityVerified'] as bool? ?? false,
    );
  }
}

class GuestBookingStatus {
  final int id;
  final String name;

  const GuestBookingStatus({required this.id, required this.name});

  factory GuestBookingStatus.fromJson(Map<String, dynamic> json) {
    return GuestBookingStatus(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

// ─── Host Bookings (POST /booking/host/bookings) ───────────────────

class HostBookingsResponse {
  final bool success;
  final HostBookingsData data;

  const HostBookingsResponse({required this.success, required this.data});

  factory HostBookingsResponse.fromJson(Map<String, dynamic> json) {
    return HostBookingsResponse(
      success: json['success'] as bool? ?? false,
      data: HostBookingsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class HostBookingsData {
  final BookingsSummary summary;
  final List<HostBooking> bookings;
  final String? message;

  const HostBookingsData({
    required this.summary,
    required this.bookings,
    this.message,
  });

  factory HostBookingsData.fromJson(Map<String, dynamic> json) {
    final raw = json['bookings'] as List<dynamic>? ?? [];
    return HostBookingsData(
      summary: BookingsSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
      bookings: raw
          .map((e) => HostBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

class HostBooking {
  final String bookingId;
  final String bookingCode;
  final String bookingType;
  final String bookingDate;
  final String bookingStartTime;
  final String bookingEndTime;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfNights;
  final String propertyId;
  final String propertyName;
  final String? propertyImageUrl;
  final GuestBookingRating propertyRating;
  final HostBookingGuest guest;
  final double totalGuestPayment;
  final GuestBookingStatus status;
  final HostBookingPayout payout;
  final GuestBookingRating hostRating;

  const HostBooking({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingType,
    required this.bookingDate,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.propertyId,
    required this.propertyName,
    this.propertyImageUrl,
    required this.propertyRating,
    required this.guest,
    required this.totalGuestPayment,
    required this.status,
    required this.payout,
    required this.hostRating,
  });

  factory HostBooking.fromJson(Map<String, dynamic> json) {
    return HostBooking(
      bookingId: json['bookingId'] as String? ?? '',
      bookingCode: json['bookingCode'] as String? ?? '',
      bookingType: json['bookingType'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingStartTime: json['bookingStartTime'] as String? ?? '',
      bookingEndTime: json['bookingEndTime'] as String? ?? '',
      checkInDate: json['checkInDate'] as String? ?? '',
      checkOutDate: json['checkOutDate'] as String? ?? '',
      numberOfNights: json['numberOfNights'] as int? ?? 0,
      propertyId: json['propertyId'] as String? ?? '',
      propertyName: json['propertyName'] as String? ?? '',
      propertyImageUrl: json['propertyImageUrl'] as String?,
      propertyRating: GuestBookingRating.fromJson(
          json['propertyRating'] as Map<String, dynamic>? ?? {}),
      guest: HostBookingGuest.fromJson(
          json['guest'] as Map<String, dynamic>? ?? {}),
      totalGuestPayment: (json['totalGuestPayment'] as num?)?.toDouble() ?? 0,
      status: GuestBookingStatus.fromJson(
          json['status'] as Map<String, dynamic>? ?? {}),
      payout: HostBookingPayout.fromJson(
          json['payout'] as Map<String, dynamic>? ?? {}),
      hostRating: GuestBookingRating.fromJson(
          json['hostRating'] as Map<String, dynamic>? ?? {}),
    );
  }

  bool get isToday {
    if (bookingDate.isEmpty) return false;
    try {
      final d = DateTime.parse(bookingDate);
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }
}

class HostBookingGuest {
  final String guestId;
  final String displayName;
  final String? profileImageUrl;
  final GuestBookingRating rating;

  const HostBookingGuest({
    required this.guestId,
    required this.displayName,
    this.profileImageUrl,
    required this.rating,
  });

  factory HostBookingGuest.fromJson(Map<String, dynamic> json) {
    return HostBookingGuest(
      guestId: json['guestId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      rating: GuestBookingRating.fromJson(
          json['rating'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class HostBookingPayout {
  final double hostPayout;
  final String payoutStatus;

  const HostBookingPayout({
    required this.hostPayout,
    required this.payoutStatus,
  });

  factory HostBookingPayout.fromJson(Map<String, dynamic> json) {
    return HostBookingPayout(
      hostPayout: (json['hostPayout'] as num?)?.toDouble() ?? 0,
      payoutStatus: json['payoutStatus'] as String? ?? '',
    );
  }
}

// ─── Guest: evaluar propiedad (POST /booking/property/review) ────────────────

class PropertyReviewRequest {
  final String bookingId;
  final double overallRating;
  final double cleanlinessRating;
  final double accuracyRating;
  final double communicationRating;
  final double locationRating;
  final double valueRating;
  final String? comment;

  const PropertyReviewRequest({
    required this.bookingId,
    required this.overallRating,
    required this.cleanlinessRating,
    required this.accuracyRating,
    required this.communicationRating,
    required this.locationRating,
    required this.valueRating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'overallRating': overallRating,
      'cleanlinessRating': cleanlinessRating,
      'accuracyRating': accuracyRating,
      'communicationRating': communicationRating,
      'locationRating': locationRating,
      'valueRating': valueRating,
    };
    if (comment != null && comment!.trim().isNotEmpty) {
      map['comment'] = comment!.trim();
    }
    return map;
  }
}

// ─── Guest: evaluar host (POST /booking/host/review) ─────────────────────────

class HostReviewRequest {
  final String bookingId;
  final double overallRating;
  final double communicationRating;
  final double cleanlinessRating;
  final double accuracyRating;
  final double checkInRating;
  final String? comment;

  const HostReviewRequest({
    required this.bookingId,
    required this.overallRating,
    required this.communicationRating,
    required this.cleanlinessRating,
    required this.accuracyRating,
    required this.checkInRating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'overallRating': overallRating,
      'communicationRating': communicationRating,
      'cleanlinessRating': cleanlinessRating,
      'accuracyRating': accuracyRating,
      'checkInRating': checkInRating,
    };
    if (comment != null && comment!.trim().isNotEmpty) {
      map['comment'] = comment!.trim();
    }
    return map;
  }
}

// ─── Guest Review (POST /booking/guest/review) ────────────────────────────────

class GuestReviewRequest {
  final String bookingId;
  final double rating;
  final double cleanlinessRating;
  final double communicationRating;
  final double respectRulesRating;
  final String? comment;
  final bool wouldHostAgain;

  const GuestReviewRequest({
    required this.bookingId,
    required this.rating,
    required this.cleanlinessRating,
    required this.communicationRating,
    required this.respectRulesRating,
    this.comment,
    required this.wouldHostAgain,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'rating': rating,
      'cleanlinessRating': cleanlinessRating,
      'communicationRating': communicationRating,
      'respectRulesRating': respectRulesRating,
      'wouldHostAgain': wouldHostAgain,
    };
    if (comment != null && comment!.trim().isNotEmpty) {
      map['comment'] = comment!.trim();
    }
    return map;
  }
}
