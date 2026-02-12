/// Modelo de imagen de una propiedad en resultados de búsqueda.
class SearchPropertyImage {
  final String imageUrl;
  final int displayOrder;

  SearchPropertyImage({
    required this.imageUrl,
    this.displayOrder = 0,
  });

  factory SearchPropertyImage.fromJson(Map<String, dynamic> json) {
    return SearchPropertyImage(
      imageUrl: json['ImageURL'] ?? json['imageUrl'] ?? json['imageURL'] ?? '',
      displayOrder: json['DisplayOrder'] ?? json['displayOrder'] ?? 0,
    );
  }
}

/// Modelo de una propiedad en resultados de búsqueda.
class SearchPropertyModel {
  final String propertyId;
  final String propertyName;
  final bool hasPool;
  final bool hasCabin;
  final bool hasCamping;
  final String location;
  final double priceFrom;
  final List<SearchPropertyImage> images;
  final String rating;
  final int reviewCount;

  SearchPropertyModel({
    required this.propertyId,
    required this.propertyName,
    this.hasPool = false,
    this.hasCabin = false,
    this.hasCamping = false,
    this.location = '',
    this.priceFrom = 0,
    this.images = const [],
    this.rating = 'Nuevo',
    this.reviewCount = 0,
  });

  factory SearchPropertyModel.fromJson(Map<String, dynamic> json) {
    return SearchPropertyModel(
      propertyId: json['propertyId'] ?? '',
      propertyName: json['propertyName'] ?? '',
      hasPool: json['hasPool'] == true,
      hasCabin: json['hasCabin'] == true,
      hasCamping: json['hasCamping'] == true,
      location: json['location'] ?? '',
      priceFrom: (json['priceFrom'] ?? 0).toDouble(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) =>
                  SearchPropertyImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rating: json['rating']?.toString() ?? 'Nuevo',
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  /// URL de la imagen principal (primera por DisplayOrder).
  String get coverImageUrl => images.isNotEmpty ? images.first.imageUrl : '';

  /// Lista de URLs de todas las imágenes.
  List<String> get imageUrls => images.map((e) => e.imageUrl).toList();

  /// Texto con los tipos de espacio disponibles.
  String get tiposDisplay {
    final tipos = <String>[];
    if (hasPool) tipos.add('Alberca');
    if (hasCabin) tipos.add('Cabaña');
    if (hasCamping) tipos.add('Camping');
    return tipos.isNotEmpty ? tipos.join(', ') : '';
  }
}

/// Respuesta paginada del endpoint GET /properties/search.
class SearchPropertiesResponse {
  final bool success;
  final int totalCount;
  final int page;
  final int pageSize;
  final List<SearchPropertyModel> properties;

  SearchPropertiesResponse({
    required this.success,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.properties,
  });

  factory SearchPropertiesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SearchPropertiesResponse(
      success: json['success'] == true,
      totalCount: data['totalCount'] ?? 0,
      page: data['page'] ?? 1,
      pageSize: data['pageSize'] ?? 20,
      properties: (data['properties'] as List<dynamic>?)
              ?.map((e) =>
                  SearchPropertyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
