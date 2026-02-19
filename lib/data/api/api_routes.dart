class ApiRoutes {
  // AUTH
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const loginWithGoogle = '/auth/google';
  static const forgotPassword = '/auth/forgot-password';

  // USERS
  static const me = '/users/me';
  static const updateProfile = '/users/me';
  static const updateImage = '/users/me/image';
  static const completeHostOnboarding = '/users/me/complete-host-onboarding';

  // PROPERTIES
  static const properties = '/properties';
  static const myProperties = '/properties/my';
  static const searchProperties = '/properties/search';
  static const propertyById = '/properties/by-id';

  // FAVORITES
  static const favorites = '/properties/favorites';
  static const favoriteIds = '/properties/favorites/ids';
  static const removeFavorite = '/properties/favorites';

  /// Catálogo de amenidades (GET /catalogs/amenities). Query: category=pool|cabin|camping (varios separados por coma).
  static const catalogAmenities = '/catalogs/amenities';
  static String amenitiesByCategory(String categories) =>
      '$catalogAmenities?category=$categories';

  // BOOKING
  static const bookingCalendar = '/booking/calendar';

  // UPDATE DE PROPIEDAD (host)
  static const updateBasicInfo = '/properties/update/basic-info';
  static const updatePoolAmenities = '/properties/update/pool-amenities';
  static const updateCabinAmenities = '/properties/update/cabin-amenities';
  static const updateCampingAmenities = '/properties/update/camping-amenities';
  static const updateRules = '/properties/update/rules';
  static const updateImages = '/properties/update/images';
  static const ownerStatus = '/properties/owner/status';

  // STRIPE CONNECT
  static const stripeConnectCreateAccount = '/stripe/connect/create-account';
  static const stripeAccountStatus = '/stripe/account-status';

  // KYC / Verificación (Didit)
  static const kycStart = '/kyc/start';
  static const kycStatus = '/kyc/status';

  // Catálogos (ubicación)
  static const catalogStates = '/catalogs/states';
  static String catalogCities(int stateId) => '/catalogs/cities/$stateId';
}
