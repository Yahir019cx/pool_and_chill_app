class AmenityModel {
  final String id;
  final String name;
  final String category;
  final String? icon;

  const AmenityModel({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    if (icon != null) 'icon': icon,
  };
}

class AmenitiesByCategory {
  final Map<String, List<AmenityModel>> _amenities;

  AmenitiesByCategory(this._amenities);

  factory AmenitiesByCategory.fromList(List<AmenityModel> list) {
    final map = <String, List<AmenityModel>>{};
    for (final amenity in list) {
      map.putIfAbsent(amenity.category, () => []).add(amenity);
    }
    return AmenitiesByCategory(map);
  }

  List<AmenityModel> forCategory(String category) => _amenities[category] ?? [];

  List<String> get categories => _amenities.keys.toList();

  bool get isEmpty => _amenities.isEmpty;
}
