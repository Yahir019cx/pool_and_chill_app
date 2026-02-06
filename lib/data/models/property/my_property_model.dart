class MyPropertyModel {
  final String id;
  final String title;
  final String? description;
  final MyPropertyStatus status;
  final bool hasPool;
  final bool hasCabin;
  final bool hasCamping;
  final int currentStep;
  final MyPropertyLocation? location;
  final List<MyPropertyImage> images;
  final double priceFrom;
  final double rating;
  final int totalReservations;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MyPropertyModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.hasPool = false,
    this.hasCabin = false,
    this.hasCamping = false,
    this.currentStep = 0,
    this.location,
    this.images = const [],
    this.priceFrom = 0,
    this.rating = 0,
    this.totalReservations = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory MyPropertyModel.fromJson(Map<String, dynamic> json) {
    return MyPropertyModel(
      id: json['propertyId'] ?? json['id'] ?? '',
      title: json['propertyName'] ?? json['title'] ?? '',
      description: json['description'],
      status: json['status'] is Map<String, dynamic>
          ? MyPropertyStatus.fromJson(json['status'])
          : MyPropertyStatus(code: json['status'] ?? 'PENDING'),
      hasPool: json['hasPool'] == true,
      hasCabin: json['hasCabin'] == true,
      hasCamping: json['hasCamping'] == true,
      currentStep: json['currentStep'] ?? 0,
      location: json['location'] != null
          ? MyPropertyLocation.fromJson(json['location'])
          : null,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => MyPropertyImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      priceFrom: (json['priceFrom'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      totalReservations: json['totalReservations'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  bool get isActive => status.code == 'ACTIVE';
  bool get isPaused => status.code == 'PAUSED';
  bool get isPending => status.code == 'PENDING';

  String get coverImageUrl =>
      images.isNotEmpty ? images.first.url : '';

  List<String> get imageUrls =>
      images.map((e) => e.url).toList();

  String get locationDisplay {
    if (location == null) return '';
    if (location!.formattedAddress.isNotEmpty) return location!.formattedAddress;
    final parts = <String>[];
    if (location!.city.isNotEmpty) parts.add(location!.city);
    if (location!.state.isNotEmpty) parts.add(location!.state);
    return parts.join(', ');
  }
}

class MyPropertyStatus {
  final int? id;
  final String? name;
  final String code;

  MyPropertyStatus({
    this.id,
    this.name,
    required this.code,
  });

  factory MyPropertyStatus.fromJson(Map<String, dynamic> json) {
    return MyPropertyStatus(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? 'PENDING',
    );
  }
}

class MyPropertyLocation {
  final String formattedAddress;
  final String city;
  final String state;

  MyPropertyLocation({
    this.formattedAddress = '',
    this.city = '',
    this.state = '',
  });

  factory MyPropertyLocation.fromJson(Map<String, dynamic> json) {
    return MyPropertyLocation(
      formattedAddress: json['formattedAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

class MyPropertyImage {
  final String url;
  final bool isPrimary;
  final int displayOrder;

  MyPropertyImage({
    required this.url,
    this.isPrimary = false,
    this.displayOrder = 0,
  });

  factory MyPropertyImage.fromJson(Map<String, dynamic> json) {
    return MyPropertyImage(
      url: json['imageUrl'] ?? json['url'] ?? '',
      isPrimary: json['isPrimary'] == true,
      displayOrder: json['displayOrder'] ?? json['order'] ?? 0,
    );
  }
}
