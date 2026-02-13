/// Elemento del catálogo GET /catalogs/states
class StateCatalogItem {
  final int id;
  final String name;

  const StateCatalogItem({required this.id, required this.name});

  factory StateCatalogItem.fromJson(Map<String, dynamic> json) {
    final id = json['ID_State'] ?? json['id'];
    final name = json['StateName'] ?? json['name'] ?? '';
    return StateCatalogItem(
      id: id is int ? id : int.tryParse(id?.toString() ?? '0') ?? 0,
      name: name.toString(),
    );
  }
}

/// Elemento del catálogo GET /catalogs/cities/:stateId
class CityCatalogItem {
  final int id;
  final String name;

  const CityCatalogItem({required this.id, required this.name});

  factory CityCatalogItem.fromJson(Map<String, dynamic> json) {
    final id = json['ID_City'] ?? json['id'];
    final name = json['CityName'] ?? json['name'] ?? '';
    return CityCatalogItem(
      id: id is int ? id : int.tryParse(id?.toString() ?? '0') ?? 0,
      name: name.toString(),
    );
  }
}
