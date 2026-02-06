class ApiRoutes {
  // AUTH
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';

  // USERS
  static const me = '/users/me';
  static const updateProfile = '/users/me';
  static const updateImage = '/users/me/image';
  static const completeHostOnboarding = '/users/me/complete-host-onboarding';

  // PROPERTIES
  static const properties = '/properties';
  static const myProperties = '/properties/my';
  static const propertiesAmenities = '/properties/catalogs/amenities';

  /// Obtiene amenidades filtradas por categorías (ej: "pool,cabin,camping")
  static String amenitiesByCategory(String categories) =>
      '$propertiesAmenities?category=$categories';
}
